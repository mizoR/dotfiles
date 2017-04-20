which go >/dev/null 2>&1
if test $status -eq 0
  set -gx GOROOT `go env GOROOT`
  set -gx GOPATH $HOME
  set -gx PATH $PATH $GOROOT/bin $GOPATH/bin
end

if test -d .rbenv
  set -gx PATH $HOME/.rbenv/bin $PATH
  rbenv init - | source
end

if test -d .plenv
  set -gx PLENV_ROOT $HOME/.plenv
  set -gx PATH $PLENV_ROOT/bin $PATH
  plenv init - | source
end
