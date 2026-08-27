import { expect, test } from "bun:test";
import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const checker = join(here, "check-plan.mjs");

function run(file: string) {
	return spawnSync(process.execPath, [checker, file], { encoding: "utf8" });
}

test("valid fixture exits 0", () => {
	const r = run(join(here, "fixtures/plan-valid.md"));
	expect(r.status).toBe(0);
	expect(r.stdout).toContain("1 PR sections, 0 problems");
});

test("missing file is usage", () => {
	const r = spawnSync(process.execPath, [checker], { encoding: "utf8" });
	expect(r.status).toBe(2);
	expect(r.stderr).toContain("Usage:");
});
