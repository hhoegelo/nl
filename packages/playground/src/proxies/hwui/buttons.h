#pragma once

#include <nltools/enums/EnumTools.h>

ENUM(Buttons, uint16_t, FIRST_PARAMETER_BUTTON = 0,

     BUTTON_0 = 0, BUTTON_1, BUTTON_2, BUTTON_3, BUTTON_4, BUTTON_5, BUTTON_6, BUTTON_7, BUTTON_8, BUTTON_9, BUTTON_10,
     BUTTON_11, BUTTON_12, BUTTON_13, BUTTON_14, BUTTON_15, BUTTON_16, BUTTON_17, BUTTON_18, BUTTON_19, BUTTON_20,
     BUTTON_21, BUTTON_22, BUTTON_23, BUTTON_24, BUTTON_25, BUTTON_26, BUTTON_27, BUTTON_28, BUTTON_29, BUTTON_30,
     BUTTON_31, BUTTON_32, BUTTON_33, BUTTON_34, BUTTON_35, BUTTON_36, BUTTON_37, BUTTON_38, BUTTON_39, BUTTON_40,
     BUTTON_41, BUTTON_42, BUTTON_43, BUTTON_44, BUTTON_45, BUTTON_46, BUTTON_47, BUTTON_48, BUTTON_49, BUTTON_50,
     BUTTON_51, BUTTON_52, BUTTON_53, BUTTON_54, BUTTON_55, BUTTON_56, BUTTON_57, BUTTON_58, BUTTON_59, BUTTON_60,
     BUTTON_61, BUTTON_62, BUTTON_63, BUTTON_64, BUTTON_65, BUTTON_66, BUTTON_67, BUTTON_68, BUTTON_69, BUTTON_70,
     BUTTON_71, BUTTON_72, BUTTON_73, BUTTON_74, BUTTON_75, BUTTON_76, BUTTON_77, BUTTON_78, BUTTON_79, BUTTON_80,
     BUTTON_81, BUTTON_82, BUTTON_83, BUTTON_84, BUTTON_85, BUTTON_86, BUTTON_87, BUTTON_88, BUTTON_89, BUTTON_90,
     BUTTON_91, BUTTON_92, BUTTON_93, BUTTON_94, BUTTON_95,

     BUTTON_SETUP = 96, BUTTON_SOUND = 97,

     BUTTON_A = 98, BUTTON_B = 99, BUTTON_C = 100, BUTTON_D = 101,

     BUTTON_STORE = 102, BUTTON_PRESET = 103, BUTTON_INFO = 104, BUTTON_FINE = 105, BUTTON_ENTER = 106,
     BUTTON_EDIT = 107, BUTTON_SHIFT = 108, BUTTON_DEFAULT = 109, BUTTON_DEC = 110, BUTTON_INC = 111, BUTTON_UNDO = 112,
     BUTTON_REDO = 113, BUTTON_ENCODER = 114,

     BUTTON_MINUS = 120, BUTTON_PLUS = 121, BUTTON_FUNCTION = 122, BUTTON_MODE = 123,

     NUM_BUTTONS = 128,

     ROTARY_MINUS, ROTARY_PLUS,

     INVALID);