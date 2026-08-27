import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { spawnSync } from "node:child_process";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const installer = join(here, "install-roles.sh");

test("project scope writes qualified role files", () => {
	const dir = mkdtempSync(join(tmpdir(), "pstack-roles-"));
	try {
		const r = spawnSync("bash", [installer, "project"], { cwd: dir, encoding: "utf8" });
		expect(r.status).toBe(0);
		const dest = join(dir, ".grok/roles");
		const xhigh = readFileSync(join(dest, "grok-pstack:pstack-xhigh.toml"), "utf8");
		expect(xhigh).toContain('reasoning_effort = "xhigh"');
		expect(xhigh).toContain('model = "grok-4.6"');
		const high = readFileSync(join(dest, "grok-pstack:poteto-agent.toml"), "utf8");
		expect(high).toContain('reasoning_effort = "high"');
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});
