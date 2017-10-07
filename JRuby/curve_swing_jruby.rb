require 'java'

java_import 'javax.swing.JFrame'
java_import 'javax.swing.JPanel'
java_import 'java.awt.Dimension'

class MyPanel < JPanel
  def paintComponent(graphics)
    1000.times do |i|
      x = Math.sin(i) + 1
      y = Math.cos(i * 0.2) + 1
      graphics.draw_oval(x * 320, y * 240, 10, 10)
    end
  end
end

frame = JFrame.new 'Hello, JRuby!'
frame.size = Dimension.new 640, 480
panel = MyPanel.new
frame.add panel
frame.visible = true