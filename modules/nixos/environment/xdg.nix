{self, ...}: let
  template = self.lib.templates.xdg;
in {
  environment = {
    variables = template.global;
  };
}
