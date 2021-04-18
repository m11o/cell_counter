# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative './services/main_frame'

MainFrame.new('Multiply Cell Counter').draw
