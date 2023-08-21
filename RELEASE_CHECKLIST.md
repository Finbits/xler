# Release checklist

In order to release a new version we first need to:

1. update the `README.md` and `mix.exs` with the new version
2. commit and create a tag for that version
3. push the changes to the repository with: `git push origin master --tags`
4. wait the CI to build all release files
5. run `rm -rf _build && mix compile --force && mix rustler_precompiled.download Xler.Native --all --printb --ignore-unavailable`
6. Commit and push the checksum file 

