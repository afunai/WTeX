#!/usr/bin/env ruby
# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require 'strscan'

class WikiTeX

  module Characters
    SPECIAL_MAP = {
      '#' => '\\#{}',
      '$' => '\\${}',
      '%' => '\\%{}',
      '&' => '\\&{}',
      '_' => '\\_{}',
      '<' => '\\textless{}',
      '>' => '\\textgreater{}',
      '^' => '\\textasciitilde{}',
      '|' => '\\textbar{}',
      '~' => '\\textasciicircum{}',
    }
    SPECIAL = SPECIAL_MAP.keys.join
    WITHOUT_RUBY = '\s|｜ぁ-んゝゞ\　、。，．？！´｀／∥…‥‘’“”（）〔〕［］｛｝〈〉《》「」『』【】♪'
  end

  def self.libdir
    ::File.dirname __FILE__
  end

  def tex(str)
    _tex str
  end

  private

  def _tex(str)
    tex  = ''
    body = ''
    type = :blank

    rex_line = /^.*(\n|\z)/
    s = StringScanner.new str

    while !s.eos? && s.scan(rex_line)
      line = s[0]
      case line
        when /^!/
          new_type = :heading
        when /^---+$/
          new_type = :newpage
        when /^$/
          new_type = :blank
        else
          new_type = :p
      end
      if (new_type != type) || single_line?(new_type)
        tex += __send__("element_#{type}", body.to_s)
        body = ''
      end
      body += line
      type = new_type
    end
    tex += __send__("element_#{type}", body) if body != ''

    tex
  end

  def single_line?(type)
    [:heading, :newpage].include? type
  end

  def element_heading(body)
    body.chomp!
    body.gsub!(/(!+)\s*/, '')
    case $1
      when '!'
        "\\chapter{#{body}}\n"
      when '!!'
        "\\section{#{body}}\n"
      else
        "\\subsection{#{body}}\n"
    end
  end

  def element_newpage(body)
    "\\newpage\n"
  end

  def element_p(body)
    body.gsub!(/\n*\Z/, '')
    body.gsub!(/\n/, "\\\\\\\\\n")
    "#{inline(body)}\n"
  end

  def element_blank(body)
    body
  end

  def inline(body)
    body = convert_ruby    body
    body = escape_specials body
  end

  def convert_ruby(body)
    body.gsub!(/[｜\|]?([^#{Characters::WITHOUT_RUBY}]+)《(.+?)》/u, '\\\\ruby{\\1}{\\2}')
    body
  end

  def escape_specials(body)
    body.gsub!(/[#{Characters::SPECIAL}]/) { Characters::SPECIAL_MAP[$&] }
    body
  end

  def skip_tex_markup(s)
    ''
  end

end
