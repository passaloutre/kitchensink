/*
 * MATLAB Compiler: 4.8 (R2008a)
 * Date: Fri Apr 18 17:07:29 2008
 * Arguments: "-B" "macro_default" "-o" "caltrackgui" "-W"
 * "WinMain:caltrackgui" "-d" "D:\mcode\caltrack\caltrackgui\src" "-T"
 * "link:exe" "-v" "-N" "D:\mcode\caltrack\caltrackgui.m" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_caltrackgui_session_key[] = {
    '7', '7', '5', 'E', '7', 'D', '5', '9', '8', '9', '1', '1', '4', 'D', 'C',
    '3', '8', '2', 'F', 'F', 'C', '6', '5', '4', '9', '8', '7', '9', 'B', '5',
    '7', '9', 'E', 'D', '2', '2', 'F', 'F', '1', '2', 'F', 'A', '6', 'A', '1',
    'D', '7', '9', 'E', '4', '1', '5', '3', 'D', '1', '2', '9', 'D', 'C', 'B',
    '9', '9', 'E', '7', '8', '1', 'A', '4', '3', '5', 'D', '0', 'B', '8', '3',
    'A', '8', 'C', 'D', 'D', '5', 'C', '3', '6', '1', 'B', '7', '5', '6', '1',
    '2', '3', '2', 'B', 'F', 'D', '5', '2', 'B', 'F', 'D', '8', 'C', '5', '6',
    '5', 'B', 'E', 'D', '8', 'E', 'C', '6', '9', '1', '5', '7', '8', '0', '6',
    '8', '3', 'F', '5', '9', '3', '0', '5', 'C', '8', '2', '1', 'C', '2', '8',
    '7', '8', 'D', '1', '5', 'D', 'C', '2', 'B', 'F', '2', 'D', '0', '5', 'E',
    'E', '2', 'B', 'D', '7', 'B', '3', '5', 'C', 'E', '1', 'B', 'E', 'B', '9',
    'E', '6', '5', '6', 'A', '8', '4', '3', '7', '2', 'E', '8', 'E', '4', 'A',
    'C', '9', 'D', 'A', 'B', '3', '4', '5', 'B', 'C', 'D', '0', '8', '7', 'F',
    'C', '7', '4', 'B', 'F', '1', '6', '6', 'D', '9', '3', '6', 'D', 'F', '5',
    'E', 'A', '4', 'F', '3', 'E', '0', 'E', '2', '3', '6', '8', '4', '4', '2',
    '9', '5', '8', 'F', '5', 'E', '8', 'B', 'F', '8', '7', '3', '5', '3', '2',
    '4', 'F', '5', 'D', '9', '4', '6', 'B', 'E', 'A', 'E', 'B', '9', '1', '4',
    '5', '\0'};

const unsigned char __MCC_caltrackgui_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_caltrackgui_matlabpath_data[] = 
  { "caltrackgui/", "toolbox/compiler/deploy/",
    "$TOOLBOXMATLABDIR/general/", "$TOOLBOXMATLABDIR/ops/",
    "$TOOLBOXMATLABDIR/lang/", "$TOOLBOXMATLABDIR/elmat/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/", "$TOOLBOXMATLABDIR/graphics/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/strfun/",
    "$TOOLBOXMATLABDIR/imagesci/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/timefun/",
    "$TOOLBOXMATLABDIR/datatypes/", "$TOOLBOXMATLABDIR/verctrl/",
    "$TOOLBOXMATLABDIR/codetools/", "$TOOLBOXMATLABDIR/helptools/",
    "$TOOLBOXMATLABDIR/winfun/", "$TOOLBOXMATLABDIR/demos/",
    "$TOOLBOXMATLABDIR/timeseries/", "$TOOLBOXMATLABDIR/hds/",
    "$TOOLBOXMATLABDIR/guide/", "$TOOLBOXMATLABDIR/plottools/",
    "toolbox/local/", "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/",
    "mcode/m_map/", "mcode/utilities/", "mcode/utilities/adcirc/" };

static const char * MCC_caltrackgui_classpath_data[] = 
  { "" };

static const char * MCC_caltrackgui_libpath_data[] = 
  { "" };

static const char * MCC_caltrackgui_app_opts_data[] = 
  { "" };

static const char * MCC_caltrackgui_run_opts_data[] = 
  { "" };

static const char * MCC_caltrackgui_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_caltrackgui_component_data = { 

  /* Public key data */
  __MCC_caltrackgui_public_key,

  /* Component name */
  "caltrackgui",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_caltrackgui_session_key,

  /* Component's MATLAB Path */
  MCC_caltrackgui_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  40,

  /* Component's Java class path */
  MCC_caltrackgui_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_caltrackgui_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_caltrackgui_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_caltrackgui_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "caltrackgui_F8A0CB2FB6B40D15A309099ADD19F0EF",

  /* MCR warning status data */
  MCC_caltrackgui_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


