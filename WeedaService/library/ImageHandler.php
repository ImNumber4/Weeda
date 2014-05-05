<?php

 	const UPLOAD_BASE_PATH = './upload/';
	
	/**
	 * Save Avatar file to server.
	 *
	 * @param $file <p>
	 * $_FILES['avatar']
	 * </p>
	 * @param $user_id <p>
	 * The current user id.
	 * </p>
	 * 
	 * @return bool true on success.
	 *
	 */
	function saveAvatarToServer($file, $user_id) {
		$error = 'Error uploading file';
		switch( $file['error'] ) {
			case UPLOAD_ERR_OK:
				$error = false;;
				break;
			case UPLOAD_ERR_INI_SIZE:
			case UPLOAD_ERR_FORM_SIZE:
				$error .= ' - file too large (limit of '.get_max_upload().' bytes).';
				break;
			case UPLOAD_ERR_PARTIAL:
				$error .= ' - file upload was not completed.';
				break;
			case UPLOAD_ERR_NO_FILE:
				$error .= ' - zero-length file uploaded.';
				break;
			case UPLOAD_ERR_NO_TMP_DIR:
				$error .= ' - tmp file no exist.';
				break;
			case UPLOAD_ERR_CANT_WRITE:
				$error .= ' - file cannot write.';
				break;
			default:
				$error .= ' - internal error #'.$_FILES['avatar']['error'];
				break;
		}
		
		
		if( !$error ) {
			if( !is_uploaded_file($_FILES['avatar']['tmp_name']) ) {
				$error = 'Error uploading file - unknown error.';
				error_log($message);
				return false;
			} else {
				$destinationPath = get_user_profile_filepath($user_id);
				if (!file_exists($destinationPath)) {
					if (!mkdir($destinationPath, 0777, true)) {
						$error = error_get_last();
    					error_log($error['message']);
					}
					error_log('ceart directory: ' . $destinationPath);
				}
				
				if (move_uploaded_file ( $file['tmp_name'], $destinationPath . '/' . $file['name'])){
					error_log ( "Stored in: " . $destinationPath . $_FILES ["avatar"] ["name"] );
				} else {
					$error = 'Error uploading file - move file failed.';
					error_log($error);
					return false;
				}
			}
		} else {
			error_log('Upload file failed: ' . $error);
		}
		return true;
	}
	
	/**
	 * Get Avatar
	 * @param  $user_id
	 * @param  $quality
	 * @return $resouce
	 */
	function getAvatarFromServer($user_id, $quality) {
		if (!isset($user_id)) {
			error_log('Input error, user_id is null.');
			return null;
		}
		
		$filename = get_user_profile_filename($user_id);
		if (!file_exists($filename)) {
			error_log('Get Image failed - Image not exist. Filepath: ' . $filename);
			return null;
		}
		
		$image = imagecreatefromjpeg($filename);
		if (!$image) {
			error_log('Get Image failed - Loading error.');
			return null;
		}
		ob_start();
		imagejpeg($image, null, $quality);
		$contents =  ob_get_contents();
		ob_end_clean();
		
		imagedestroy($image);
		return base64_encode($contents);
	}
	
	/**
	 * Save Weeds image to server
	 * 
	 * @param $tmp_image <p>
	 * The tmp file of upload file ($_FILES['file']['tmp_name']).
	 * </p>
	 * @param $user_id <p>
	 * The current user id.
	 * </p>
	 * @param $weed_id <p>
	 * The id of weed which contained this image.
	 * </p>
	 * 
	 * @return bool, true on success.
	 * 
	 */
	
	function saveImageForWeedsToServer($tmp_image, $user_id, $weed_id) {
		
	}
	
	function get_user_profile_filepath($user_id) {
		return UPLOAD_BASE_PATH . $user_id . '/avatar/';
	}
	
	function get_user_profile_filename($user_id) {
		return UPLOAD_BASE_PATH . $user_id . '/avatar/avatar.jpeg';
	}
	
	function get_weed_image_filepath($user_id, $weed_id, $count) {
		return UPLOAD_BASE_PATH . $user_id . '/' . $weed_id . '/' . $count . '.jpeg';
	}

?>