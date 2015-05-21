class String
  def replace_separator(sepatator)
    if self.include?("+")
      self.split("+").join(sepatator)
    else
      self
    end
  end

  def nil_or_empty?
    empty?
  end

end

class NilClass
  def nil_or_empty?
    true
  end
end