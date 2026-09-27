<a href="https://puppetflow.com"><img src="https://www.puppetflow.com/img/puppetflow-promo-banner.png" width="100%" alt="Puppetflow" /></a>

# Puppetflow piece for Activepieces

[![npm](https://img.shields.io/npm/v/@puppetflow/piece-puppetflow?label=npm)](https://www.npmjs.com/package/@puppetflow/piece-puppetflow)
[![CI](https://github.com/puppetflow/activepieces-piece-puppetflow/actions/workflows/ci.yml/badge.svg)](https://github.com/puppetflow/activepieces-piece-puppetflow/actions/workflows/ci.yml)

An [Activepieces](https://www.activepieces.com) piece for [Puppetflow](https://puppetflow.com), the self-hosted browser automation platform. Trigger Puppeteer flows from your Activepieces flows, wait for them to finish, and reuse their results, screenshots, downloads, and session recordings in the next steps.

Works with Puppetflow Cloud and self-hosted Puppetflow instances.

## Installation

The piece is published on npm and can be installed on any self-hosted Activepieces instance. It is not part of the Activepieces main repository because unsolicited pull requests are currently paused there.

1. In Activepieces, open **Settings > Pieces** (platform admin).
2. Click **Install Piece**.
3. Enter the package name `@puppetflow/piece-puppetflow` and the version you want, for example `0.1.0`.

If your instance cannot reach npm, download the `.tgz` bundle attached to a [release](https://github.com/puppetflow/activepieces-piece-puppetflow/releases) and upload it with the **Package archive** option instead.

## Connection

The piece authenticates with the Puppetflow REST API.

| Field | Value |
| --- | --- |
| Instance URL | Base URL of your Puppetflow instance, for example `https://your-team.puppetflow.com` |
| API Key | In Puppetflow, click your name at the bottom-left of the sidebar, open **Profile > API Keys**, and create a key. It is shown only once. |

The connection is validated with a call to `GET /api/v1/flows` when you save it.

## Actions

| Action | Description |
| --- | --- |
| Trigger Flow | Start a flow with optional input and return the run ID immediately |
| Trigger Flow and Wait | Start a flow, poll its status, and return the completed run with its output |
| Search Flows | Find flows by name, description, ID, type, or folder |
| Get Run | Full run details: status, output, error, timing, human validation state, artifact links |
| Get Run Result | Output, status, and timing only |
| List Runs | Paginated runs of one flow, with status filter |
| Search Runs | Runs across all flows, with the same filters as the Puppetflow Runs page |
| Continue Run | Resume a run paused by `$waitHumanValidation()` |
| List Artifacts | Screenshots or downloaded files produced by a run |
| Download Artifact | Fetch one screenshot or downloaded file as an Activepieces file |
| Download Recording | Fetch the MP4 session recording, or only its last frame as JPEG |
| Custom API Call | Call any `/api/v1` endpoint with the connection credentials |

Flow and run pickers are searchable dropdowns populated from your instance. When you select a flow, the **Flow Inputs** section lists the inputs declared by that flow (`input_definitions` or `default_inputs`), and values are coerced to the declared type before the run starts. An **Additional Input** JSON object can be merged on top.

Every action exposes `classification`, `audience`, and `aiMetadata`, so the piece can also be used by Activepieces agents.

## Development

The piece source lives in `src/` and follows the structure of a community piece in the Activepieces monorepo.

Activepieces pieces are shipped as self-contained bundles: the `@activepieces/*` libraries are inlined by the monorepo build tooling and are not available on npm. `scripts/build.sh` therefore clones `activepieces/activepieces` at a pinned commit, copies this piece into `packages/pieces/community/puppetflow`, runs the official `build-piece` command, and copies the result to `dist/`.

```bash
npm run build:bundle
```

Requirements: Node 20 or later, [Bun](https://bun.sh), Git.

To publish a new version, bump `version` in `package.json`, then push a matching tag. The release workflow builds the bundle, publishes it to npm, and attaches the `.tgz` to a GitHub release.

```bash
git tag v0.1.1
git push origin v0.1.1
```

## Related

- [Puppetflow](https://github.com/puppetflow/puppetflow)
- [Puppetflow REST API reference](https://docs.puppetflow.com/reference/api)
- [n8n community node](https://github.com/puppetflow/n8n-nodes-puppetflow)
- [Upstream Activepieces pull request](https://github.com/activepieces/activepieces/pull/15833)

## License

MIT
