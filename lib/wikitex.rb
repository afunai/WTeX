#!/usr/bin/env ruby
# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require 'strscan'

class WikiTeX

  module Characters
    SPECIAL_MAP = {
      '#' => '\\#{}',
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
    line = ''
    type = :blank

    markups  = []
    rex_line = /(.*?)(\\|\$\$?|\{|\n|\z)/
    s = StringScanner.new str

    while !s.eos? && s.scan(rex_line)
      line += s[1]

      if s[2] =~ /\\|\$|\{/
        line += skip_tex_markup(s, s[2], markups)
        next unless s.match? /\z/
      end

      new_type = wiki_type line

      if (new_type != type) || single_line?(type)
        tex += __send__("element_#{type}", body.to_s)
        body = ''
      end

      body << line << "\n"
      type = new_type
      line = ''
    end

    tex += __send__("element_#{type}", body.to_s)
    tex.gsub(/\x00(\d+)/) { markups[$1.to_i] }
  end

  def skip_tex_markup(s, type, markups)
    if type == '\\'
      if s.scan /begin\{(.+?)\}/
        markups << scan_inner_contents(s, "\\begin{#{s[1]}}", "\\end{#{s[1]}}")
      elsif s.scan /verb/
        markups << (s.scan(/(.).*?\1/) ? "\\verb#{s[0]}" : '$\backslash$verb')
      elsif s.scan /.\w*/
        markups << ('\\' + s[0]) # command or escaped character
      end
    elsif type == '$$'
      markups << (s.scan(%r/.*?[^\\]\$\$|\$\$/m) ? "$$#{s[0]}" : '\\${}\\${}')
    elsif type == '$'
      markups << (s.scan(%r/.*?[^\\]\$|\$/m) ? "$#{s[0]}" : '\\${}')
    elsif type == '{'
      markups << scan_inner_contents(s, '{', '}')
    else
      return '???'
    end
    "\x00#{markups.size - 1}"
  end

  def scan_inner_contents(s, open_tag, close_tag)
    contents = ''
    rex = /(.*?)(\\?#{Regexp.quote(open_tag)}|\\?#{Regexp.quote(close_tag)}|\z)/m
    gen = 1
    until s.eos? || (gen < 1)
      contents << s.scan(rex)
      gen += 1 if s[2] == open_tag
      gen -= 1 if s[2] == close_tag
    end
    open_tag + contents
  end

  def wiki_type(line)
    case line
      when /^!/
        :heading
      when /^---+$/
        :newpage
      when /^$/
        :blank
      else
        :p
    end
  end

  def single_line?(type)
    [:heading, :newpage].include? type
  end

  def element_heading(body)
    body.chomp!
    body.gsub!(/(!+)\s*/, '')
    case $1
      when '!'
        "\\subsection{#{body}}\n"
      when '!!'
        "\\section{#{body}}\n"
      else
        "\\chapter{#{body}}\n"
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

end
