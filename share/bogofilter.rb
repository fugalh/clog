module Clog
  class Bogofilter < Agent
    def initialize
      @tot_spamicity = 0.0
      @lines = 0
      @tally = {"Spam"=>0,"Ham"=>0,"Unsure"=>0}
    end
    def handle(line,handled)
      case line
      when / bogofilter\[\d+\]: X-Bogosity: (Spam|Ham|Unsure), spamicity=([\d.]+)/
	@lines += 1	
	@tally[$1] += 1
	@tot_spamicity += $2.to_f
	return :consumed
      else
	return :unhandled
      end
    end
    def report
      return "Nothing to report." unless @lines > 0
      spam = @tally['Spam']
      unsure = @tally['Unsure']
      ham = @tally['Ham']
      linesf = @lines.to_f
      <<EOF
Spam:  \t#{spam}\t(#{sprintf("%2d",100*spam/linesf)}%)
Unsure:\t#{unsure}\t(#{sprintf("%2d",100*unsure/linesf)}%)
Ham:   \t#{ham}\t(#{sprintf("%2d",100*ham/linesf)}%)

Average spamicity: #{@tot_spamicity/linesf}
EOF
    end
  end
end
