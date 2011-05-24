#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

################### by cloud ###################################
class DocumentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/documents"
  end

  def filename
    model.random_string + File.extname(@filename) if @filename
  end

end
##################### end ######################################
