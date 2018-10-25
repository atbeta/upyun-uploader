# Dropzone Action Info
# Name: upyun Uploader
# Description: 又拍云上传并直接生成Markdown链接，修改自官方FTP上传工具。
# Handles: Files
# Creator: Beta
# URL: https://pbeta.me
# OptionsNIB: ExtendedLogin
# Events: Dragged, TestConnection
# KeyModifiers: Option
# SkipConfig: No
# RunsSandboxed: Yes
# Version: 1.0
# MinDropzoneVersion: 3.0

require 'ftp'

$host_info = {:server    => ENV['server'],
              :port      => ENV['port'],
              :username  => ENV['username'],
              :password  => ENV['password']}

def dragged
  delete_zip = false
  
  if ENV['KEY_MODIFIERS'] == "Option"
      # Zip up files before uploading
      if $items.length == 1
          # Use directory or file name as zip file name
          dir_name = $items[0].split(File::SEPARATOR)[-1]
          file = ZipFiles.zip($items, "#{dir_name}.zip")
          else
          file = ZipFiles.zip($items, "files.zip")
      end
      
      # Remove quotes
      items = [file[1..-2]]
      delete_zip = true
      else
      # Recursive upload
      items = $items
  end
  
  $dz.begin("Starting transfer...")
  $dz.determinate(false)
  
  remote_paths = FTP.do_upload(items, ENV['remote_path'], $host_info)
  ZipFiles.delete_zip(items) if delete_zip
  
  # Put URL of uploaded file on pasteboard
  finish_text = "Upload Complete"

  if remote_paths.length == 1
    filename = remote_paths[0].split(File::SEPARATOR)[-1].strip

    if ENV['root_url'] != nil
        if ENV['remote_path'] !=nil
        slash = (ENV['root_url'][-1,1] == "/" ? "" : "/")
        url_raw = ENV['root_url'] + slash + ENV['remote_path'] + filename
        url = "!["+filename+"]"+"("+url_raw+")"
        finish_text = "URL is now on clipboard"
        else
        slash = (ENV['root_url'][-1,1] == "/" ? "" : "/")
        url_raw = ENV['root_url'] + slash + filename
        url = "!["+filename+"]"+"("+url_raw+")"
        finish_text = "URL is now on clipboard"
        end
    else
      url = filename
    end
  else
    url = false
  end
  
  $dz.finish(finish_text)
  $dz.text(url)
end

def test_connection
  FTP.test_connection($host_info)
end
