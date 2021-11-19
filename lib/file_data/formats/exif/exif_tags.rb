module FileData
  TagNameInfo = Struct.new(:name, :is_known);

  # Contains tag number to name information taken from the exif spec
  class ExifTags
    singleton_class.class_eval { attr_accessor :tag_groups }
    @tag_groups = {}

    def self.get_tag_name(ifd_id, tag_id)
      known_name = get_known_name(ifd_id, tag_id)
      TagNameInfo.new(known_name || "#{ifd_id}-#{tag_id}".to_sym, known_name != nil)
    end

    def self.get_known_name(ifd_id, tag_id)
      ifd_group = tag_groups[ifd_id]
      ifd_group[tag_id] unless ifd_group.nil?
    end
  end
end

# Tiff Tags (0th and 1st IFDs)
FileData::ExifTags.tag_groups[:Tiff] =
  {
    256 => :Image_Structure_Width,
    257 => :Image_Structure_Length,
    258 => :Image_Structure_BitsPerSample,
    259 => :Image_Structure_Compression,
    262 => :Image_Structure_PhotometricInterpretation,
    270 => :Other_ImageDescription,
    271 => :Other_Make,
    272 => :Other_Model,
    273 => :Recording_StripOffsets,
    274 => :Image_Structure_Orientation,
    277 => :Image_Structure_SamplesPerPixel,
    278 => :Recording_RowsPerStrip,
    279 => :Recording_StripByteCounts,
    283 => :Image_Structure_YResolution,
    284 => :Image_Structure_PlanarConfiguration,
    296 => :Image_Structure_ResolutionUnit,
    301 => :Image_Data_TransferFunction,
    305 => :Other_Software,
    306 => :Other_DateTime,
    315 => :Other_Artist,
    318 => :Image_Data_WhitePoint,
    319 => :Image_Data_PrimaryChromaticities,
    513 => :Recording_JPEGInterchangeFormat,
    514 => :Recording_JPEGInterchangeFormatLength,
    529 => :Image_Data_YCbCrCoefficients,
    530 => :Image_Structure_YCbCrSubSampling,
    531 => :Image_Structure_YCbCrPositioning,
    532 => :Image_Data_ReferenceBlackWhite,
    33_432 => :Other_Copyright
  }

# Exif IFD Tags
FileData::ExifTags.tag_groups[34_665] =
  {
    33_434 => :Exif_PictureTakingConditions_ExposureTime,
    33_437 => :Exif_PictureTakingConditions_FNumber,
    34_850 => :Exif_PictureTakingConditions_ExposureProgram,
    34_852 => :Exif_PictureTakingConditions_SpectralSensitivity,
    34_855 => :Exif_PictureTakingConditions_PhotographicSensitivity,
    34_856 => :Exif_PictureTakingConditions_OECF,
    34_864 => :Exif_PictureTakingConditions_SensitivityType,
    34_865 => :Exif_PictureTakingConditions_StandardOutputSensitivity,
    34_866 => :Exif_PictureTakingConditions_RecommendedExposureIndex,
    34_867 => :Exif_PictureTakingConditions_ISOSpeed,
    34_868 => :Exif_PictureTakingConditions_ISOSpeedLatitudeyyy,
    34_869 => :Exif_PictureTakingConditions_ISOSpeedLatitudezzz,
    36_864 => :Exif_Version_ExifVersion,
    36_867 => :Exif_DateAndTime_DateTimeOriginal,
    36_868 => :Exif_DateAndTime_DateTimeDigitized,
    37_121 => :Exif_Configuration_ComponentsConfiguration,
    37_122 => :Exif_Configuration_CompressedBitsPerPixel,
    37_377 => :Exif_PictureTakingConditions_ShutterSpeedValue,
    37_378 => :Exif_PictureTakingConditions_ApertureValue,
    37_379 => :Exif_PictureTakingConditions_BrightnessValue,
    37_380 => :Exif_PictureTakingConditions_ExposureBiasValue,
    37_381 => :Exif_PictureTakingConditions_MaxApertureValue,
    37_382 => :Exif_PictureTakingConditions_SubjectDistance,
    37_383 => :Exif_PictureTakingConditions_MeteringMode,
    37_384 => :Exif_PictureTakingConditions_LightSource,
    37_385 => :Exif_PictureTakingConditions_Flash,
    37_396 => :Exif_PictureTakingConditions_SubjectArea,
    37_386 => :Exif_PictureTakingConditions_FocalLength,
    37_500 => :Exif_Configuration_MakerNote,
    37_510 => :Exif_Configuration_UserComment,
    37_520 => :Exif_DateAndTime_SubsecTime,
    37_521 => :Exif_DateAndTime_SubsecTimeOriginal,
    37_522 => :Exif_DateAndTime_SubsecTimeDigitized,
    37_888 => :Exif_ShootingSituation_Temperature,
    37_889 => :Exif_ShootingSituation_Humidity,
    37_890 => :Exif_ShootingSituation_Pressure,
    37_891 => :Exif_ShootingSituation_WaterDepth,
    37_892 => :Exif_ShootingSituation_Acceleration,
    37_893 => :Exif_ShootingSituation_CameraElevationAngle,
    40_960 => :Exif_Version_FlashpixVersion,
    40_961 => :Exif_ColorSpace_ColorSpace,
    40_962 => :Exif_Configuration_PixelXDimension,
    40_963 => :Exif_Configuration_PixelYDimension,
    40_964 => :Exif_RelatedFile_RelatedSoundFile,
    41_483 => :Exif_PictureTakingConditions_FlashEnergy,
    41_484 => :Exif_PictureTakingConditions_SpatialFrequencyResponse,
    41_486 => :Exif_PictureTakingConditions_FocalPlaneXResolution,
    41_487 => :Exif_PictureTakingConditions_FocalPlaneYResolution,
    41_488 => :Exif_PictureTakingConditions_FocalPlanResolutionUnit,
    41_492 => :Exif_PictureTakingConditions_SubjectLocation,
    41_493 => :Exif_PictureTakingConditions_ExposureIndex,
    41_495 => :Exif_PictureTakingConditions_SensingMode,
    41_728 => :Exif_PictureTakingConditions_FileSource,
    41_729 => :Exif_PictureTakingConditions_SceneType,
    41_730 => :Exif_PictureTakingConditions_CFAPattern,
    41_985 => :Exif_PictureTakingConditions_CustomRendered,
    41_986 => :Exif_PictureTakingConditions_ExposureMode,
    41_987 => :Exif_PictureTakingConditions_WhiteBalance,
    41_988 => :Exif_PictureTakingConditions_DigitalZoomRatio,
    41_989 => :Exif_PictureTakingConditions_FocalLengthIn35mmFilm,
    41_990 => :Exif_PictureTakingConditions_SceneCaptureType,
    41_991 => :Exif_PictureTakingConditions_GainControl,
    41_992 => :Exif_PictureTakingConditions_Contrast,
    41_993 => :Exif_PictureTakingConditions_Saturation,
    41_994 => :Exif_PictureTakingConditions_Sharpness,
    41_995 => :Exif_PictureTakingConditions_DeviceSettingDescription,
    41_996 => :Exif_PictureTakingConditions_SubjectDistanceRange,
    42_016 => :Exif_Other_ImageUniqueID,
    42_032 => :Exif_Other_CameraOwnerName,
    42_033 => :Exif_Other_BodySerialNumber,
    42_034 => :Exif_Other_LensSpecification,
    42_035 => :Exif_Other_LensMake,
    42_036 => :Exif_Other_LensModel,
    42_037 => :Exif_Other_LensSerialNumber,
    42_240 => :Exif_ColorSpace_Gamma
  }

# GPS IFD Tags
FileData::ExifTags.tag_groups[34_853] =
  {
    0 => :GPS_Version,
    1 => :GPS_LatitudeRef,
    2 => :GPS_Latitude,
    3 => :GPS_LongitudeRef,
    4 => :GPS_Longitude,
    5 => :GPS_AltitudeRef,
    6 => :GPS_Altitude,
    7 => :GPS_TimeStamp,
    8 => :GPS_Satellites,
    9 => :GPS_Status,
    10 => :GPS_MeasureMode,
    11 => :GPS_DOP,
    12 => :GPS_SpeedRef,
    13 => :GPS_Speed,
    14 => :GPS_TrackRef,
    15 => :GPS_Track,
    16 => :GPS_ImgDirectionRef,
    17 => :GPS_ImgDirection,
    18 => :GPS_MapDatum,
    19 => :GPS_DestLatitudeRef,
    20 => :GPS_DestLatitude,
    21 => :GPS_DestLongitudeRef,
    22 => :GPS_DestLongitude,
    23 => :GPS_DestBearingRef,
    24 => :GPS_DestBearing,
    25 => :GPS_DestDistanceRef,
    26 => :GPS_DestDistance,
    27 => :GPS_ProcessingMethod,
    28 => :GPS_AreaInformation,
    29 => :GPS_DateStamp,
    30 => :GPS_Differential,
    31 => :GPS_HPositioningError
  }

# Interoperability IFD Tags
FileData::ExifTags.tag_groups[40_965] =
  {
    1 => :Interoperability_Index
  }
