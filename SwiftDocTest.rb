class SwiftDocTest < Formula
  desc "TODO"
  homepage "TODO"
  url "https://github.com/schwa/SwiftDocTest.git",
      tag:      "0.0.1"
  license "BSD/3"
  head "https://github.com/schwa/SwiftDocTest.git", branch: "main"

  depends_on xcode: ["14.1", :build]
  depends_on xcode: "13.0"

  uses_from_macos "swift"

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release"
    bin.install ".build/release/SwiftDocTest"
  end
end
