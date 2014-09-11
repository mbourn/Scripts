#!/usr/bin/ruby -w
###############################################################################
###### Item superclass #########
###############################################################################

class Item
  # Vars
  attr_accessor :name, :parentDir, :permissions, :itemType

  # Methods
  def findItem(root, tgt, type)
    case type

  #####################################
      when 1
        root.each do |x|
          if x.instance_of?FileItem
            next
          end
          if x.instance_of?LinkItem
            next
          end
          if x.name == tgt
            return true
          end
          if x.instance_of?DirItem
            return (findItem(x.fileList, tgt, type))
          end
        end
        print "" # I don't know why, but removing this breaks the function

  #####################################
      when 2
        if (root.size==0)
          return false
        end
        root.each do|x|
          if x.instance_of?DirItem
            return (findItem(x.fileList, tgt, type))
          end
          if x.name == tgt
            return true
          end
        end

  #####################################
      when 3
    end
  end
end

###############################################################################
##### DirItem subclass #####
###############################################################################
class DirItem < Item
  # Vars
  attr_accessor :upddate, :fileList

  # Methods
  def initialize( fileList = Array.new )
    @fileList = fileList
  end

  ## Recursively print all sub files and dirs
  def printDir(root)
    if root.parentDir == "/"
      puts "/"+root.name
    else
      puts "/"+root.parentDir+"/"+root.name
    end
    root.fileList.each do |x|
      if (x.instance_of?(FileItem))
        puts " "+x.name
      end
      if (x.instance_of?(LinkItem))
        puts " "+x.name+"\!"
      end
      if x.instance_of?(DirItem)
        printDir(x)
      end
    end
    puts "** End of /"+root.name+" Dir **"
  end

  def insertDir(root, tgtName, newDir)
    root.each do |x|
      if x.name == tgtName
        x.fileList.insert(-1, newDir)
      elsif x.instance_of?(DirItem) && x.name != tgtName
        insertDir(x.fileList, tgtName, newDir)
      end
    end
  end
end

###############################################################################
##### FileItem subclass #####
###############################################################################
class FileItem < Item
  attr_accessor :size

  ## Methods
  def insertFile(root, tgtDir, newFile)
    root.each do |x|
      if x.name == tgtDir
        x.fileList.insert(-1, newFile)
      elsif x.instance_of?DirItem
        insertFile(x.fileList, tgtDir, newFile)
      end
    end
  end
end

###############################################################################
##### LinkItem subclass #####
###############################################################################
class LinkItem < Item
  attr_accessor :tgtfile

  ## Methods
  def insertLink(root, tgtDir, newLink)
    root.each do |x|
      if (x.name == tgtDir)
        x.fileList.insert(-1, newLink)
      elsif x.instance_of?DirItem
        insertLink(x.fileList, tgtDir, newLink)
      end
    end
  end
end

############################################
##### Program Starts #######################
############################################
isDir=1
isFl=2
isLk=3
bashCmd = system( "clear")
root=Array.new
#root=DirItem.new
#root.name="/"
#root.parentDir=nil
#root.permissions="rwx"

## Infinite loop to repeat menu until quit
while true do

  ##Print main menu
  puts " "
  puts "Welcome to Ruby's File System"
  puts "-----------------------------"
  puts "Main Menu:"
  puts "1. Create a File"
  puts "2. Create a Directory"
  puts "3. Create a Link"
  puts "4. Remove a File/Directory/Link"
  puts "5. Display File System"
  puts "6. Exit"
  print "Choice: "
  choice = gets.chomp

  case choice.to_i
    when 1
###############################################################################
      ## Create the object
      newFile = FileItem.new

      ## Get and set the vars
      print "Please enter File name or quit: "
      newFile.name = gets.chomp
      if newFile.name == "quit"
        redo
      end
      if (newFile.findItem(root, newFile.name, isFl))
        puts "That file already exists, please try again"
        redo
      end
      print "Please enter a parent directory or quit: "
      newFile.parentDir = gets.chomp
      if newFile.parentDir == "quit"
        redo
      end
      if (newFile.parentDir !="/" && !newFile.findItem(root, newFile.parentDir, isDir))
        puts "That directory does not exist, please try again"
        redo
      end
      print "Please enter access permissions using format rwx or quit: "
      newFile.permissions = gets.chomp
      if newFile.permissions == "quit"
        redo
      end
      print "Please enter size (1-Small, 2-Medium, 3-Large): "
      newFileSize = gets.chomp

      ## Insert it into the structure
      if newFile.parentDir == "/"
        root.push( newFile )
      else
        temp = newFile.parentDir.split("/")
        tgtDir = temp[-1]
        newFile.insertFile(root, tgtDir, newFile)
      end
###############################################################################
    when 2
      ## Create the object
      newDir = DirItem.new

      ## Get and set the vars
      print "Please enter the directory name or quit: "
      newDir.name = gets.chomp
      if newDir.name == "quit"
        redo
      end
      if (newDir.name == "/" || newDir.findItem(root, newDir.name, isDir))
        puts "That directory already exists, please try again"
        redo
      end
      print "Please enter a parent directory or quit: "
      newDir.parentDir = gets.chomp
      if newDir.parentDir == "quit"
        redo
      end
      ## Check to see if the parent dir exists
      if (newDir.parentDir!="/" && !newDir.findItem(root, newDir.parentDir, isDir))
        puts "That directory does not exist, please try again"
        redo
      end
      print "Please enter the access permissions using format rwx or quit: "
      newDir.permissions = gets.chomp
      if newDir.permissions == "quit"
        redo
      end

      ## Insert it into the structure
      if newDir.parentDir == "/"
        root.push( newDir )
      else
        temp = newDir.parentDir.split("/")
        tgtDir = temp[-1]
        newDir.insertDir(root, tgtDir, newDir)
      end
###############################################################################
    when 3
      puts "Please enter the name of the file to which you wish to link, "
      print "or type quit: "
      newLink=LinkItem.new
      newLink.name=gets.chomp
      if (newLink.name == "quit")
        redo
      end
      if (!newLink.findItem(root, newLink.name, isFl) &&
          !newLink.findItem(root, newLink.name, isDir))
        puts "That file does not exist, please try again"
        redo
      end
      print "Please enter the parent directory or quit: "
      newLink.parentDir=gets.chomp
      if  (newLink.parentDir=="quit")
        redo
      end
      if (newLink.parentDir!="/" &&
          !newLink.findItem(root, newLink.parentDir, isDir))
        puts "That directory does not exist, please try again"
        redo
      end
      print "Pleaes enter the access permissions using the format rwx or quit: "
      newLink.permissions=gets.chomp
      if (newLink.permissions=="quit")
        redo
      end

      # Add the link to the file structure
      if (newLink.parentDir == "/")
        root.push(newLink)
      end

###############################################################################
    when 4
      puts "Under Construction"
      puts " "
###############################################################################
    when 5
      puts "/"
      root.each do |y|
        if y.instance_of?(DirItem)
          y.printDir(y)
        else
        puts "  "+y.name
      end
    end
###############################################################################
    when 6
      puts "Goodbye!"
      exit
    else
      puts "ERROR. Try again."
      puts " "
    end
  end
