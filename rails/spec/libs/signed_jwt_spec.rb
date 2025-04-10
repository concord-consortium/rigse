# frozen_string_literal: false

require 'spec_helper'

RSpec.describe SignedJwt do

  describe "#is_valid_private_key?" do

    it "fails on a invalid private key" do
      expect(SignedJwt::is_valid_private_key?("foo")).to be false
    end

    it "succeeds on a valid private key" do
      valid_private_key = "-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDzAReCWkVgF2eOAMvRRr6i1XOqVO7kcwbczahVR48ZhhmStJaU
P7aZKL9L3bgvQvL9D8T9zFwYjyGiaY5czdob79Z/R+0yReID7Aix7vuFf8e7Hfxk
ltDnCh9jcMTKUMeS4rx8dbAG0XtXkD7ayxv5wfBfaDl5GvtY88eLKgCi9QIDAQAB
AoGBAJP9TjvsjeN/XWl1wqqo0uCH7fEF2Jb4Fm3SMXn+IoAA0wItSKbwRlvwHNAv
L0RZGXJUcDvAgTXTtUAb2L9b/j9lc1/KzZbPFdJDe/A2vqoet8y2Fu955LeS2cPB
0AcCZeTfxtj65wrabapI+gRb6vsHo49FPh4PG3F+NzJZnZrhAkEA/XDgxS/fa0yX
PlUWiGjdDNSclkvbohJcDhQDtAJqbKxeL/xzgobDl4mCylrhsclIPUmXoMjvd8TB
qjqm7f+pdwJBAPV1PGmCqaUwRzY0lXuEBz2fj1RNT7yh5qHT6eZmrFTpb+B/UxXz
gEd86P++bdlXD9CAQFv0ss7sFK90DW71MfMCQCyuU9IvyHHARQHGOny+EAqNCTYu
FYCTQAtzV9vKeTzDfq9zEGI4pA75PUezkgqn88ZqTQMZqa4xz/rU8E0RP60CQQCC
LD5xpj3ZwRTDBngQHSDJ6YjVqHqVCzeIsx3kdqcGERan9F5X0d9CClh26MLQ9H8K
kDmRiuAZJNKDigRlx9tJAkAdrkzo40+vsucH9OxOcR7KkUfufL1EWC4qcqH46oDX
gpZlAvdO9CFaBcBKsAcJnNDQBY2lhFsSeqYs78PoW7Zz
-----END RSA PRIVATE KEY-----"
      expect(SignedJwt::is_valid_private_key?(valid_private_key)).to be true
    end

  end

end
