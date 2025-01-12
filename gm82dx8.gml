#define __gm82dx8_init
    if (execute_string("return get_function_address('display_get_orientation')") <= 0) {
        globalvar __gm82dx8_time;
        __gm82dx8_time=__gm82dx8_time_now()
        
        if (variable_global_get("__gm82core_version")>134) {
            //recent enough core extension: let's work together
            object_event_add(core,ev_other,ev_animation_end,"dx8_vsync()")
        } else {
            //core extension not detected: let's do it ourselves
            object_event_add(__gm82dx8_obj,ev_destroy,0,"instance_copy(0)")
            object_event_add(__gm82dx8_obj,ev_other,ev_room_end,"persistent=true")
            object_event_add(__gm82dx8_obj,ev_other,ev_animation_end,"dx8_vsync()")
            object_set_persistent(__gm82dx8_obj,1)
            room_instance_add(room_first,0,0,__gm82dx8_obj)
        }
        return 0
    }
    show_error("Sorry, but Game Maker 8.2 DirectX8 requires Game Maker 8.2.",1)
    return 1


#define dx8_set_alphablend
    ///dx8_enable_alphablend(enable)
    YoYo_EnableAlphaBlend(argument0)


#define dx8_make_opaque
    ///dx8_make_opaque()
    draw_set_blend_mode(bm_add)
    draw_rectangle_color(-9999999,-9999999,9999999,9999999,0,0,0,0,0)
    draw_set_blend_mode(0)


#define dx8_surface_engage
    ///dx8_surface_engage(id,width,height)
    var __s;__s=argument0
    if (surface_exists(__s)) {
        if (surface_get_width(__s)==argument1 && surface_get_height(__s)==argument2) {
            surface_set_target(__s)
            return __s
        }
    }
    __s=surface_create(argument1,argument2)
    surface_set_target(__s)
    return __s


#define dx8_surface_discard
    ///dx8_surface_discard(id)
    if (surface_exists(argument0)) {
        surface_free(argument0)
    }


#define dx8_surface_disengage
    ///dx8_surface_disengage()
    if (variable_global_get("__gm82core_appsurf_interop")) {
        dx8_surface_engage(application_surface,core.__resw,core.__resh)
    } else {
        surface_reset_target()
        dx8_reset_projection()
    }    


#define dx8_reset_projection
    ///dx8_reset_projection()
    if (view_enabled)
        d3d_set_projection_ortho(view_xview[view_current],view_yview[view_current],view_wview[view_current],view_hview[view_current],view_angle[view_current])
    else
        d3d_set_projection_ortho(0,0,room_width,room_height,0)

    
#define dx8_set_fullscreen_ext
    ///dx8_set_exclusive_fullscreen(enabled)
    if (argument0 ^ window_get_fullscreen()) {
        if (window_get_fullscreen()) {
            __gm82dx8_setfullscreen(0)
            window_set_fullscreen(0)
            return 1
        } else {
            window_set_fullscreen(1)
            __gm82dx8_setfullscreen(display_get_frequency())
            return 1
        }
    }    
    return 0


#define dx8_projection_simple
    ///dx8_set_projection_simple(x,y,w,h,angle,dollyzoom,depthmin,depthfocus,depthmax)
    var __xfrom,__yfrom,__zfrom;

    if (argument5<=0) {
        // ¯\_(º_o)_/¯
        d3d_set_projection_ortho(argument0,argument1,argument2,argument3,argument4)
    } else {
        __xfrom=argument0+argument2/2
        __yfrom=argument1+argument3/2    
        __zfrom=min(-tan(degtorad(90*(1-argument5)))*argument3/2,argument6-argument7)

        d3d_set_projection_ext(
            __xfrom,__yfrom,__zfrom+argument7,                           //from
            __xfrom,__yfrom,argument7,                                   //to
            lengthdir_x(1,-argument4+90),lengthdir_y(1,-argument4+90),0, //up
            -point_direction(__zfrom,0,0,argument3/2)*2,                 //angle
            -argument2/argument3,                                        //aspect
            max(1,argument6-argument7-__zfrom),                          //znear
            argument8-argument7-__zfrom                                  //zfar
        )
    }
    

#define dx8_vsync
    //only activate if vsyncable
    if (room_speed==display_get_frequency()) {    
        //we do timed wakeups every 1ms to check the time
        while (!__gm82dx8_waitvblank()) {
             __gm82dx8_sleep(1)
             if (__gm82dx8_time_now()-__gm82dx8_time>1000000/room_speed-2000) {
                //Oh my fur and whiskers! I'm late, I'm late, I'm late!
                break
            }
        }

        //busywait for vblank
        while (!__gm82dx8_waitvblank()) {/*òwó*/}
        __gm82dx8_time=__gm82dx8_time_now()

        //sync DWM
        __gm82dx8_sleep(3)

        //epic win
    }


