# transferwise/download-repo-artifact Action

This action downloads artifacts produced by previous workflow runs in
the same repository.  These don't have to have been uploaded by the same
workflow.

If you want to download an artifact in the same workflow run as it was
uploaded, see
[actions/download-artifact](https://github.com/actions/download-artifact).

## Example usage

```
uses: transferwise/download-repo-artifact@v1
with:
  name: service-jar
  path: lib/build/      # default: . (current directory)
```
