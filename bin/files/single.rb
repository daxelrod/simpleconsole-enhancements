#!/usr/bin/env ruby -w
require "rubygems"
require "simpleconsole"
# require File.dirname(__FILE__) + "/../"

class _Controller_ < SimpleConsole::Controller
end

class _View_ < SimpleConsole::View
end

SimpleConsole::Application.run(ARGV, _Controller_, _View_)
