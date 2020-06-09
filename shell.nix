{ pkgs ? import <nixpkgs> {} }:


pkgs.mkShell {
  # nixpkgs.config.allowUnfree = true; 
  buildInputs = with pkgs; [
    pry
    openssl # can be specific version too
    ruby # ruby_2_3 # specific ruby version
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
