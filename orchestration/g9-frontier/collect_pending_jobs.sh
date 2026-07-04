#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  orchestration/g9-frontier/collect_pending_jobs.sh [--execute] [--host HOST] [--only all|g8|airbench]

Default mode is dry-run. Dry-run prints the collection plan and does not call SSH.

Options:
  --execute        Run the non-mutating remote collection commands and local pulls.
  --host HOST      SSH host alias to use. Default: leonardo.
  --only TARGET    Collect only one target: all, g8, or airbench. Default: all.
  -h, --help       Show this help.
USAGE
}

MODE="dry-run"
SSH_HOST="leonardo"
ONLY="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute)
      MODE="execute"
      shift
      ;;
    --host)
      SSH_HOST="${2:?--host requires a value}"
      shift 2
      ;;
    --only)
      ONLY="${2:?--only requires a value}"
      case "$ONLY" in
        all|g8|airbench) ;;
        *) echo "ERROR invalid --only value: $ONLY" >&2; exit 2 ;;
      esac
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
COLLECTION_STAMP="${TS}-pid$$"

remote_quote() {
  local value="$1"
  printf "'%s'" "${value//\'/\'\\\'\'}"
}

planned() {
  printf '[dry-run] %s\n' "$*"
}

note() {
  printf '%s\n' "$*"
}

already_collected() {
  local local_runtime="$1"
  local job_id="$2"
  local run_id="$3"
  find "$local_runtime/collections" -mindepth 2 -maxdepth 2 -name COLLECTION_COMPLETE.txt -type f 2>/dev/null \
    | while IFS= read -r marker; do
        if grep -q "JOB_ID=$job_id" "$marker" && grep -q "RUN_ID=$run_id" "$marker"; then
          printf '%s\n' "$marker"
          return 0
        fi
      done
}

run_ssh_capture() {
  local out_file="$1"
  local err_file="$2"
  local remote_cmd="$3"
  if [[ "$MODE" == "dry-run" ]]; then
    planned "ssh $SSH_HOST \"$remote_cmd\" > $(rel "$out_file") 2> $(rel "$err_file")"
    return 0
  fi

  set +e
  ssh "$SSH_HOST" "$remote_cmd" >"$out_file" 2>"$err_file"
  local rc=$?
  set -e
  return "$rc"
}

run_rsync_pull() {
  local log_file="$1"
  shift
  if [[ "$MODE" == "dry-run" ]]; then
    planned "$* > $(rel "$log_file") 2>&1"
    return 0
  fi

  set +e
  "$@" >"$log_file" 2>&1
  local rc=$?
  set -e
  return "$rc"
}

remote_test_dir() {
  local remote_dir="$1"
  local out_file="$2"
  local err_file="$3"
  local q_dir
  q_dir="$(remote_quote "$remote_dir")"
  run_ssh_capture "$out_file" "$err_file" "test -d $q_dir"
}

rel() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) printf '%s' "${path#"$ROOT_DIR"/}" ;;
    *) printf '%s' "$path" ;;
  esac
}

main_state_from_sacct() {
  local sacct_file="$1"
  local job_id="$2"
  awk -F'|' -v job="$job_id" '$1 == job { print $3; exit }' "$sacct_file" 2>/dev/null || true
}

is_terminal_state() {
  local state="$1"
  case "$state" in
    COMPLETED|FAILED|CANCELLED*|TIMEOUT|OUT_OF_MEMORY|NODE_FAIL|PREEMPTED|BOOT_FAIL|DEADLINE|REVOKED|SPECIAL_EXIT)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

write_metadata() {
  local file="$1"
  local label="$2"
  local job_id="$3"
  local run_id="$4"
  local local_runtime="$5"
  local remote_checkout="$6"
  local remote_output="$7"
  local expected_record="$8"
  local expected_validation="$9"
  local runs="${10}"
  local base_seed="${11}"
  local commit="${12}"
  local launch_env="${13}"

  cat >"$file" <<EOF
LABEL=$label
JOB_ID=$job_id
RUN_ID=$run_id
LOCAL_RUNTIME=$local_runtime
REMOTE_CHECKOUT=$remote_checkout
REMOTE_OUTPUT=$remote_output
EXPECTED_RECORD=$expected_record
EXPECTED_VALIDATION_SOURCE=$expected_validation
EXPECTED_RUNS=$runs
BASE_SEED=$base_seed
EXPECTED_COMMIT=$commit
LAUNCH_ENV=$launch_env
COLLECTION_TIMESTAMP_UTC=$TS
COLLECTION_MODE=$MODE
SSH_HOST=$SSH_HOST
EOF
}

write_status() {
  local status_file="$1"
  local label="$2"
  local job_id="$3"
  local run_id="$4"
  local state="$5"
  local remote_output_present="$6"
  local output_dir="$7"

  local summary="UNKNOWN"
  if [[ -z "$state" ]]; then
    summary="UNKNOWN: sacct did not return a top-level state for $job_id"
  elif is_terminal_state "$state"; then
    summary="TERMINAL: $state"
  else
    summary="NONTERMINAL: $state"
  fi

  {
    printf '# Collection Status: %s\n\n' "$label"
    printf -- '- Job id: `%s`\n' "$job_id"
    printf -- '- Run id: `%s`\n' "$run_id"
    printf -- '- Scheduler summary: `%s`\n' "$summary"
    printf -- '- Remote output directory present: `%s`\n' "$remote_output_present"
    printf -- '- Local collection directory: `%s`\n\n' "$(rel "$output_dir")"
    printf 'This file records collection state only. It does not interpret metrics.\n\n'
    printf '## Required Artifact Presence\n\n'
    local out_root="$output_dir/remote_outputs/$run_id"
    for path in \
      "$out_root/paired_summary.json" \
      "$out_root/paired_order.csv" \
      "$out_root/stdout.log" \
      "$out_root/stderr.log"; do
      if [[ -e "$path" ]]; then
        printf -- '- present: `%s`\n' "$(rel "$path")"
      else
        printf -- '- missing: `%s`\n' "$(rel "$path")"
      fi
    done

    local config_count metrics_count summary_count warmup_count repro_count diff_count
    config_count="$(find "$out_root" -name config.json -type f 2>/dev/null | wc -l | tr -d ' ')"
    metrics_count="$(find "$out_root" -name metrics.csv -type f 2>/dev/null | wc -l | tr -d ' ')"
    summary_count="$(find "$out_root" -name summary.json -type f 2>/dev/null | wc -l | tr -d ' ')"
    warmup_count="$(find "$out_root" -name warmup.json -type f 2>/dev/null | wc -l | tr -d ' ')"
    repro_count="$(find "$out_root" -name repro_metadata.json -type f 2>/dev/null | wc -l | tr -d ' ')"
    diff_count="$(find "$out_root" -name git_diff.patch -type f 2>/dev/null | wc -l | tr -d ' ')"
    printf -- '- raw config files: `%s`\n' "$config_count"
    printf -- '- raw metrics files: `%s`\n' "$metrics_count"
    printf -- '- raw summary files: `%s`\n' "$summary_count"
    printf -- '- raw warmup files: `%s`\n' "$warmup_count"
    printf -- '- raw repro metadata files: `%s`\n' "$repro_count"
    printf -- '- git diff patch files: `%s`\n\n' "$diff_count"

    if [[ "$state" == "COMPLETED" && ( "$remote_output_present" != "yes" || ! -e "$out_root/paired_summary.json" || ! -e "$out_root/paired_order.csv" ) ]]; then
      printf '## Warning\n\n'
      printf 'The scheduler state is completed, but one or more required artifacts are missing locally. Treat this as incomplete until a critic verifies the remote state and raw artifacts.\n'
    elif [[ -n "$state" ]] && ! is_terminal_state "$state"; then
      printf '## Warning\n\n'
      printf 'The job is not terminal. Do not resubmit or interpret this run from partial artifacts.\n'
    fi
  } >"$status_file"
}

collect_job() {
  local slug="$1"
  local label="$2"
  local job_id="$3"
  local run_id="$4"
  local local_runtime_rel="$5"
  local remote_checkout="$6"
  local expected_record="$7"
  local expected_validation="$8"
  local runs="$9"
  local base_seed="${10}"
  local commit="${11}"
  local launch_env="${12}"

  local local_runtime="$ROOT_DIR/$local_runtime_rel"
  local remote_output="$remote_checkout/outputs/cifar100_speedrun/$run_id"
  local previous
  previous="$(already_collected "$local_runtime" "$job_id" "$run_id" || true)"

  if [[ -n "$previous" ]]; then
    note "SKIP $label: already collected at $(rel "$previous")"
    return 0
  fi

  local collection_dir="$local_runtime/collections/${COLLECTION_STAMP}-${slug}-${job_id}"
  note "Target: $label"
  note "  job: $job_id"
  note "  run: $run_id"
  note "  remote checkout: $remote_checkout"
  note "  remote output: $remote_output"
  note "  local collection: $(rel "$collection_dir")"
  note "  expected: RECORD=$expected_record VALIDATION_SOURCE=$expected_validation RUNS=$runs BASE_SEED=$base_seed"

  if [[ "$MODE" == "dry-run" ]]; then
    note "  mode: dry-run, no SSH or local writes"
  else
    mkdir -p "$local_runtime/collections"
    mkdir "$collection_dir"
    mkdir -p "$collection_dir"/{remote_checks,remote_outputs,scheduler_logs,rsync_logs}
    write_metadata \
      "$collection_dir/metadata.env" \
      "$label" "$job_id" "$run_id" "$local_runtime_rel" "$remote_checkout" "$remote_output" \
      "$expected_record" "$expected_validation" "$runs" "$base_seed" "$commit" "$launch_env"
  fi

  local q_output q_logs q_checkout
  q_output="$(remote_quote "$remote_output")"
  q_logs="$(remote_quote "$remote_checkout/logs")"
  q_checkout="$(remote_quote "$remote_checkout")"

  local sacct_cmd="sacct -j $job_id --format=JobID,JobName%30,State,ExitCode,Elapsed,NodeList%30,AllocTRES%120 -P"
  local manifest_cmd="find $q_output -maxdepth 3 -type f \\( -name 'paired_summary.json' -o -name 'paired_order.csv' -o -name 'stdout.log' -o -name 'stderr.log' -o -name 'config.json' -o -name 'metrics.csv' -o -name 'summary.json' -o -name 'warmup.json' -o -name 'repro_metadata.json' -o -name 'git_diff.patch' \\) -print"
  local stat_cmd="find $q_output -maxdepth 3 -type f \\( -name 'paired_summary.json' -o -name 'paired_order.csv' -o -name 'stdout.log' -o -name 'stderr.log' -o -name 'config.json' -o -name 'metrics.csv' -o -name 'summary.json' -o -name 'warmup.json' -o -name 'repro_metadata.json' -o -name 'git_diff.patch' \\) -exec stat -c '%n	%s	%Y' {} +"
  local sha_cmd="find $q_output -maxdepth 3 -type f \\( -name 'paired_summary.json' -o -name 'paired_order.csv' -o -name 'stdout.log' -o -name 'stderr.log' -o -name 'config.json' -o -name 'metrics.csv' -o -name 'summary.json' -o -name 'warmup.json' -o -name 'repro_metadata.json' -o -name 'git_diff.patch' \\) -exec sha256sum {} +"
  local log_manifest_cmd="find $q_logs -maxdepth 1 -type f \\( -name 'paired-${job_id}.out' -o -name 'paired-${job_id}.err' \\) -print"
  local checkout_manifest_cmd="find $q_checkout -maxdepth 2 -type f \\( -path '*/.git/HEAD' -o -path '*/.git/ORIG_HEAD' -o -name 'slurm-*.out' -o -name 'slurm-*.err' \\) -print"

  if [[ "$MODE" == "dry-run" ]]; then
    planned "would create $(rel "$collection_dir") with non-overwriting mkdir"
    planned "would write metadata with expected commit $commit and launch env: $launch_env"
    planned "ssh $SSH_HOST \"$sacct_cmd\""
    planned "ssh $SSH_HOST \"test -d $q_output\""
    planned "ssh $SSH_HOST \"$manifest_cmd\""
    planned "ssh $SSH_HOST \"$stat_cmd\""
    planned "ssh $SSH_HOST \"$sha_cmd\""
    planned "ssh $SSH_HOST \"$log_manifest_cmd\""
    planned "ssh $SSH_HOST \"$checkout_manifest_cmd\""
    planned "rsync -av $SSH_HOST:$remote_output/ $(rel "$collection_dir")/remote_outputs/$run_id/"
    planned "rsync -av --prune-empty-dirs --include=/logs/ --include=/logs/paired-${job_id}.out --include=/logs/paired-${job_id}.err --exclude=* $SSH_HOST:$remote_checkout/ $(rel "$collection_dir")/scheduler_logs/"
    note ""
    return 0
  fi

  local sacct_out="$collection_dir/remote_checks/sacct-${job_id}.txt"
  if ! run_ssh_capture "$sacct_out" "$collection_dir/remote_checks/sacct-${job_id}.err" "$sacct_cmd"; then
    note "ERROR $label: sacct failed; see $(rel "$collection_dir/remote_checks/sacct-${job_id}.err")"
    return 1
  fi

  local state
  state="$(main_state_from_sacct "$sacct_out" "$job_id")"
  local collection_had_errors=0
  local remote_output_rsync_status="not_attempted"
  local scheduler_log_rsync_status="not_attempted"
  if [[ -z "$state" ]]; then
    note "WARN $label: sacct returned no top-level state for $job_id"
  elif is_terminal_state "$state"; then
    note "INFO $label: scheduler state is terminal: $state"
  else
    note "WARN $label: scheduler state is not terminal: $state"
  fi

  local output_present="no"
  set +e
  remote_test_dir "$remote_output" "$collection_dir/remote_checks/test-output-dir.out" "$collection_dir/remote_checks/test-output-dir.err"
  local test_rc=$?
  set -e
  if [[ "$test_rc" -eq 0 ]]; then
    output_present="yes"
  elif [[ "$test_rc" -eq 255 ]]; then
    note "ERROR $label: SSH failed while checking remote output directory"
    return 1
  else
    note "WARN $label: remote output directory is not present: $remote_output"
  fi

  run_ssh_capture "$collection_dir/remote_checks/output-manifest.txt" "$collection_dir/remote_checks/output-manifest.err" "$manifest_cmd" || true
  run_ssh_capture "$collection_dir/remote_checks/output-stat.tsv" "$collection_dir/remote_checks/output-stat.err" "$stat_cmd" || true
  run_ssh_capture "$collection_dir/remote_checks/output-sha256.tsv" "$collection_dir/remote_checks/output-sha256.err" "$sha_cmd" || true
  run_ssh_capture "$collection_dir/remote_checks/scheduler-log-manifest.txt" "$collection_dir/remote_checks/scheduler-log-manifest.err" "$log_manifest_cmd" || true
  run_ssh_capture "$collection_dir/remote_checks/checkout-manifest.txt" "$collection_dir/remote_checks/checkout-manifest.err" "$checkout_manifest_cmd" || true

  if [[ "$output_present" == "yes" ]]; then
    if ! run_rsync_pull \
      "$collection_dir/rsync_logs/remote-output-rsync.log" \
      rsync -av "${SSH_HOST}:${remote_output}/" "$collection_dir/remote_outputs/$run_id/"; then
      note "WARN $label: remote output rsync failed; see $(rel "$collection_dir/rsync_logs/remote-output-rsync.log")"
      collection_had_errors=1
      remote_output_rsync_status="failed"
    else
      remote_output_rsync_status="ok"
    fi
  else
    remote_output_rsync_status="skipped_missing_remote_output"
  fi

  if ! run_rsync_pull \
    "$collection_dir/rsync_logs/scheduler-log-rsync.log" \
    rsync -av --prune-empty-dirs \
      --include="/logs/" \
      --include="/logs/paired-${job_id}.out" \
      --include="/logs/paired-${job_id}.err" \
      --exclude="*" \
      "${SSH_HOST}:${remote_checkout}/" "$collection_dir/scheduler_logs/"; then
    note "WARN $label: scheduler log rsync failed; see $(rel "$collection_dir/rsync_logs/scheduler-log-rsync.log")"
    collection_had_errors=1
    scheduler_log_rsync_status="failed"
  else
    scheduler_log_rsync_status="ok"
  fi

  write_status "$collection_dir/collection_status.md" "$label" "$job_id" "$run_id" "$state" "$output_present" "$collection_dir"

  local completed_required_artifacts=1
  local out_root="$collection_dir/remote_outputs/$run_id"
  local expected_raw_count=$((runs * 2))
  local config_count metrics_count summary_count warmup_count repro_count
  config_count="$(find "$out_root" -name config.json -type f 2>/dev/null | wc -l | tr -d ' ')"
  metrics_count="$(find "$out_root" -name metrics.csv -type f 2>/dev/null | wc -l | tr -d ' ')"
  summary_count="$(find "$out_root" -name summary.json -type f 2>/dev/null | wc -l | tr -d ' ')"
  warmup_count="$(find "$out_root" -name warmup.json -type f 2>/dev/null | wc -l | tr -d ' ')"
  repro_count="$(find "$out_root" -name repro_metadata.json -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$state" == "COMPLETED" ]]; then
    if [[ "$output_present" != "yes" || ! -e "$out_root/paired_summary.json" || ! -e "$out_root/paired_order.csv" ]]; then
      completed_required_artifacts=0
      note "INCOMPLETE $label: completed scheduler state but required paired artifacts are missing; no completion marker written"
    elif [[ "$config_count" -lt "$expected_raw_count" || "$metrics_count" -lt "$expected_raw_count" || "$summary_count" -lt "$expected_raw_count" || "$warmup_count" -lt "$expected_raw_count" || "$repro_count" -lt "$expected_raw_count" ]]; then
      completed_required_artifacts=0
      note "INCOMPLETE $label: completed scheduler state but raw per-run artifacts are incomplete; no completion marker written"
      note "  expected at least $expected_raw_count each for config/metrics/summary/warmup/repro, got $config_count/$metrics_count/$summary_count/$warmup_count/$repro_count"
    fi
  fi

  if [[ -n "$state" ]] && is_terminal_state "$state" && [[ "$collection_had_errors" -eq 0 && "$completed_required_artifacts" -eq 1 ]]; then
    {
      printf 'JOB_ID=%s\n' "$job_id"
      printf 'RUN_ID=%s\n' "$run_id"
      printf 'STATE=%s\n' "$state"
      printf 'COLLECTION_TIMESTAMP_UTC=%s\n' "$TS"
      printf 'COLLECTION_DIR=%s\n' "$(rel "$collection_dir")"
      printf 'REMOTE_OUTPUT_PRESENT=%s\n' "$output_present"
      printf 'REMOTE_OUTPUT_RSYNC=%s\n' "$remote_output_rsync_status"
      printf 'SCHEDULER_LOG_RSYNC=%s\n' "$scheduler_log_rsync_status"
      printf 'EXPECTED_RAW_PER_RUN_COUNT=%s\n' "$expected_raw_count"
      printf 'CONFIG_COUNT=%s\n' "$config_count"
      printf 'METRICS_COUNT=%s\n' "$metrics_count"
      printf 'SUMMARY_COUNT=%s\n' "$summary_count"
      printf 'WARMUP_COUNT=%s\n' "$warmup_count"
      printf 'REPRO_METADATA_COUNT=%s\n' "$repro_count"
    } >"$collection_dir/COLLECTION_COMPLETE.txt"
    note "OK $label: terminal collection written to $(rel "$collection_dir")"
  elif [[ "$collection_had_errors" -ne 0 ]]; then
    note "INCOMPLETE $label: one or more local pulls failed; no completion marker written"
  elif [[ "$completed_required_artifacts" -eq 0 ]]; then
    :
  else
    note "INCOMPLETE $label: nonterminal or unknown scheduler state; no completion marker written"
  fi

  note ""
}

collect_g8() {
  collect_job \
    "g8" \
    "G8-B official ns3_mom93" \
    "48463506" \
    "g8b_ns3_mom93_official_20260704T003556Z" \
    "orchestration/g8-b-muon/runtime-official-20260704T003556Z" \
    "/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun-g8b-official-clean" \
    "1" \
    "official" \
    "30" \
    "894000" \
    "4ba08a7b3fea1652411a3adcabddc33fb2821ffe" \
    "RECORD=1 VALIDATION_SOURCE=official RUNS=30 EPOCHS=13 BASE_SEED=894000 BASELINE_ENV=C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 CANDIDATE_ENV=C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93"
}

collect_airbench() {
  collect_job \
    "airbench" \
    "AirBench dev10 train-only augmentation" \
    "48463507" \
    "airbench_aug_pad2_alt_dev10_20260704T003552Z" \
    "orchestration/airbench-transfer/runtime-dev10-20260704T003552Z" \
    "/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun-airbench-transfer" \
    "0" \
    "train_dev" \
    "10" \
    "74003552" \
    "c4be9f2ae340006eeb276c6b7405b592534e74de" \
    "RECORD=0 VALIDATION_SOURCE=train_dev RUNS=10 EPOCHS=13 C100_DEV_PER_CLASS=50 C100_DEV_SPLIT_SEED=20260703 BASE_SEED=74003552 COMMON_ENV=C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 CANDIDATE_ENV=C100_TRANSLATE_PAD=2 C100_FLIP_MODE=alternating"
}

note "Collection mode: $MODE"
note "SSH host: $SSH_HOST"
note "No sbatch, scancel, rm, mv, or remote writes are used by this helper."
note ""

case "$ONLY" in
  all)
    collect_g8
    collect_airbench
    ;;
  g8)
    collect_g8
    ;;
  airbench)
    collect_airbench
    ;;
esac
