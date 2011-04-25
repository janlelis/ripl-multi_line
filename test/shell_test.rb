require File.join(File.dirname(__FILE__), 'test_helper')

describe "Shell" do
  before { reset_ripl }

  def shell(options={})
    Ripl.shell(options)
  end

  describe "multi-line behaviour" do
    should_eval %| "m" * 2 |
    should_eval %| "8989" |
    should_eval %| "zzz" |

    should_not_eval %| "m" *  |

    should_not_eval %| " |
    should_not_eval %| ' |
    should_not_eval %| / |

    should_not_eval %| [ |
    should_not_eval %| { |
    should_not_eval %| ( |

    should_not_eval %| def hey |
    should_not_eval %| def hey; 89 |
    should_not_eval %| begin |
    should_eval %| for x in [2,3,4];7;end |
  end

  # TODO add misc tests for everything
end
