{...}: {
  services.logind = {
    lidSwitch = "suspend";
    powerKey = "suspend";
  };
}
