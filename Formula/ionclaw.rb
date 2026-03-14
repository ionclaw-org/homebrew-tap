# typed: false
# frozen_string_literal: true

class Ionclaw < Formula
  desc "C++ AI agent orchestrator that runs anywhere as a native build"
  homepage "https://github.com/ionclaw-org/ionclaw"
  url "https://github.com/ionclaw-org/ionclaw.git", tag: "1.0.3"
  license "MIT"
  head "https://github.com/ionclaw-org/ionclaw.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "node" => :build

  def install
    # build web client
    system "npm", "install", "--prefix", "apps/web"
    system "npm", "run", "build", "--prefix", "apps/web"

    # build c++ binary
    system "cmake", "-S", ".", "-B", "build/release",
           "-DCMAKE_BUILD_TYPE=Release",
           "-DCMAKE_INSTALL_PREFIX=#{prefix}",
           "-DHOMEBREW_ALLOW_FETCHCONTENT=ON",
           *std_cmake_args

    jobs = [ENV.make_jobs / 2, 1].max
    ENV["CMAKE_BUILD_PARALLEL_LEVEL"] = jobs.to_s

    system "cmake", "--build", "build/release", "--config", "Release"

    system "cmake", "--install", "build/release"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ionclaw-server --version")
  end
end
