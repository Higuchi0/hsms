class HSMSMessage
  MAX_BUFFER_SIZE = 0xFFFFFFFF
  LENGTH_BYTES = 4
  SYSTEM_BYTES = 4+6
  HEADER_BYTES = 10
  
  attr_reader :buffer
  
  def initialize
    @buffer = ""
    @length = 0
  end
  
  def feed(data)
    return if remain_buffer_size == 0
    @buffer << data
  end
  
  # TODO?
  # Request resend command if received length < header bytes.
  def length
    return @length unless (@length == 0)
    return 0 if (@buffer.length < LENGTH_BYTES)
    return @length = _get_dword(0)
  end
  
  def remain_buffer_size
    return MAX_BUFFER_SIZE if (length == 0)
    return (LENGTH_BYTES + @length - @buffer.length)
  end

  def _set_dword(offset, data)
    @buffer[offset + 0] = (data >> 24) & 0xFF
    @buffer[offset + 1] = (data >> 16) & 0xFF
    @buffer[offset + 2] = (data >>  8) & 0xFF
    @buffer[offset + 3] = data & 0xFF
  end
  protected :_set_dword
  
  def _get_dword(offset)
    val = 0
    4.times { |i|
      val <<= 8
      val += @buffer[offset + i]
    }
    return val
  end
  protected :_get_dword
  
  def set_data(data)
    @buffer = "\x00" * (LENGTH_BYTES + HEADER_BYTES) + data
    @length = HEADER_BYTES + data.length
    _set_dword(0, @length)
  end
  
  def set_system_byte(system_byte)
    return if @length < HEADER_BYTES
    _set_dword(SYSTEM_BYTES, system_byte)
  end

  def get_system_byte
    return 0 if @length < HEADER_BYTES
    return _get_dword(SYSTEM_BYTES)
  end
end
