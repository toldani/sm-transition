class User
  include Enumerable

  attr_reader :tables, :forum

  def initialize(typ)
    typ.downcase!
    @forum = typ if ["xmb", "phpbb"].include?(typ)
    @tables = {}
  end

  def [](t)
    t.gsub!(/(xmb|sm)_/, '')