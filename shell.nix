{ pkgs ? import <nixpkgs> {} }:


pkgs.mkShell {
  # nixpkgs.config.allowUnfree = true; 
  buildInputs = with pkgs; [
    # pry
    openssl # can be specific version too
    zlib
    libiconv # nokogiri
    # postgresql # pg
    sqlite
    chromedriver
    geckodriver
    firefox
    chromium
    # sassc # libsass
  ];
}
