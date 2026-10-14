#!/usr/bin/env python3
"""Compare the median of three warmed profile runs per toast configuration."""
import json
import argparse
from pathlib import Path
from statistics import median

ROOT = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--before', type=Path, default=ROOT / 'results/before.json')
parser.add_argument('--after', type=Path, default=ROOT / 'results/after.json')
parser.add_argument('--output', type=Path, default=ROOT / 'results/comparison.json')
args = parser.parse_args()
before = json.loads(args.before.read_text())
after = json.loads(args.after.read_text())


def summarize(result):
    groups = {}
    for run in result['runs']:
        key = (run['toasts_per_viewer'], run['viewers'])
        groups.setdefault(key, []).append(run)
    return {
        key: {
            'build_ms': median(r['frames']['average_frame_build_time_millis'] for r in runs),
            'raster_ms': median(r['frames']['average_frame_rasterizer_time_millis'] for r in runs),
            'build_p90_ms': median(r['frames']['90th_percentile_frame_build_time_millis'] for r in runs),
            'build_p99_ms': median(r['frames']['99th_percentile_frame_build_time_millis'] for r in runs),
            'raster_p90_ms': median(r['frames']['90th_percentile_frame_rasterizer_time_millis'] for r in runs),
            'raster_p99_ms': median(r['frames']['99th_percentile_frame_rasterizer_time_millis'] for r in runs),
            'ui_frames_over_90hz_budget': median(sum(t > 1000000 / 90 for t in r['frames']['frame_build_times']) for r in runs),
            'raster_frames_over_90hz_budget': median(sum(t > 1000000 / 90 for t in r['frames']['frame_rasterizer_times']) for r in runs),
            'builder_calls': median(r['builder_calls'] for r in runs),
            'content_layouts': median(r['content_layouts'] for r in runs),
            'content_paints': median(r['content_paints'] for r in runs),
            'frames': median(r['frames']['frame_count'] for r in runs),
        }
        for key, runs in groups.items()
    }


b, a = summarize(before), summarize(after)
lines = [
    '| Toast/viewer × viewers | UI mean ms before → after | UI reduction | Raster mean ms before → after | Builder calls before → after |',
    '| --- | --- | --- | --- | --- |',
]
comparison = []
for key in b:
    old, new = b[key], a[key]
    improvement = 100 * (1 - new['build_ms'] / old['build_ms'])
    lines.append(
        f"| {key[0]} × {key[1]} | {old['build_ms']:.3f} → {new['build_ms']:.3f} | "
        f"{improvement:.1f}% | {old['raster_ms']:.3f} → {new['raster_ms']:.3f} | "
        f"{old['builder_calls']:.0f} → {new['builder_calls']:.0f} |"
    )
    comparison.append({'toasts_per_viewer': key[0], 'viewers': key[1], 'before': old, 'after': new})
args.output.write_text(json.dumps(comparison, indent=2) + '\n')
print('\n'.join(lines))
