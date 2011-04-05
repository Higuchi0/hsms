require "hsms_message"

class HSMSFactory
  MAX_SEQUENCE_NUMBER = 0xFFFFFFFF
  attr_reader :sequence_number

  def initialize(initial_number = 0)
    @sequence_number = initial_number
    clear
  end
  
  def clear
    @messages = Array.new
    @message = HSMSMessage.new
  end
  
  def [](index)
    @messages[index]
  end
  
  def <<(message)
    @messages << message
  end
  
  def each
    @messages.each { |message| 
      yield(message)
    }
  end
  
  def get_sequence_number
    @sequence_number = 0 if @sequence_number >= MAX_SEQUENCE_NUMBER
    return @sequence_number += 1
  end
  
  def feed(org_data)
    work = ""
    work << org_data
    while work.length > 0
      if @message.length == 0
        @message.feed(work.slice!(0, HSMSMessage::LENGTH_BYTES))
      end
      remain = @message.remain_buffer_size
      if remain > work.length
        @message.feed(work)
        return
      end
      @message.feed(work.slice!(0, remain))
      @messages << @message
      @message = HSMSMessage.new
    end
  end
end
