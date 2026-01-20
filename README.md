# Get Next Semantic Version Number GitHub Action

This GitHub Action calculates the next semantic version number for your repository using [Conventional Commits](https://www.conventionalcommits.org/) and your repository's commit history via the GitHub API. It supports both stable and pre-release versioning and works even if your repository does not yet have a version tag.

## Features
- Determines the next semantic version based on commit messages and existing tags.
- Uses the GitHub API (not local git) for analyzing tags and commits.
- Supports pre-release and stable release versioning.
- Can pad prerelease numbers with leading zeros for consistent formatting.
- Outputs the next version, next version tag, and the type of version bump (major, minor, patch, none).
- Handles first-time releases with a sensible default starting version.

## Inputs
| Name                    | Description                                                                                      | Required | Default |
|-------------------------|--------------------------------------------------------------------------------------------------|----------|---------|
| `prerelease`            | Mark the release as a pre-release (`true`/`false`).                                              | Yes      |         |
| `prerelease-identifier` | The identifier to append for pre-releases (e.g., "alpha", "beta", "dev").                        | Yes      |         |
| `owner`                 | GitHub repository owner (user or organization).                                                  | Yes      |         |
| `repo-name`             | Name of the repository.                                                                          | Yes      |         |
| `branch`                | Branch to analyze for commits (e.g., "main", "development").                                     | Yes      |         |
| `use-leading-zeros`     | Whether to pad the numeric prerelease identifier with leading zeros (`true`/`false`).            | No       | `false` |
| `number-of-leading-zeros` | Total width for the numeric prerelease identifier when leading zeros are enabled.               | No       | `4`     |
| `token`                 | GitHub token with repository write access                                                        | Yes      |         |

## Outputs
| Name           | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `version-number`      | The next semantic version number (e.g., `1.0.1`, `1.0.1-dev.0001`).         |
| `version-tag`  | The next version tag (e.g., `v1.0.1`, `v1.0.1-dev.0001`).                   |
| `release-type` | The bump type (`major`, `minor`, `patch`, or `none`).                       |
| `result`       | Result of getting the next version number (`success` or `failure`).         |
| `error-message`| Error message if there is a failure to get the next version number.         |

## Usage

Create a workflow file in your repository (e.g., `.github/workflows/calculate-semver.yml`).  
**Make sure you pass all required inputs and use a valid token.**

### Example Workflow

```yaml
name: Calculate Next Semantic Version
on:
  workflow_dispatch:
    inputs:
      prerelease:
        description: 'Mark as pre-release (true/false)'
        required: false
        default: 'false'
      prerelease-identifier:
        description: 'Pre-release identifier (e.g., dev, alpha, beta)'
        required: false
        default: 'dev'
      use-leading-zeros:
        description: 'Whether to pad prerelease numbers (true/false)'
        required: false
        default: 'false'
      number-of-leading-zeros:
        description: 'Width for padding prerelease numbers'
        required: false
        default: '4'

jobs:
  get-next-version:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Get Next Semantic Version
        id: semver
        uses: lee-lott-actions/get-next-semantic-verison-number@v1
        with:
          prerelease: ${{ github.event.inputs.prerelease }}
          prerelease-identifier: ${{ github.event.inputs.prerelease-identifier }}
          use-leading-zeros: ${{ github.event.inputs.use-leading-zeros }}
          number-of-leading-zeros: ${{ github.event.inputs.number-of-leading-zeros }}
          owner: ${{ github.repository_owner }}
          repo-name: ${{ github.event.repository.name }}
          branch: ${{ github.ref_name }}
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Output Version Info
        run: |
          echo "Next Version: ${{ steps.semver.outputs.version-number }}"
          echo "Next Version Tag: ${{ steps.semver.outputs.version-tag }}"
          echo "Release Type: ${{ steps.semver.outputs.release-type }}"
          echo "Result: ${{ steps.semver.outputs.result }}"
          echo "Error Message: ${{ steps.semver.outputs.error-message }}"
```
