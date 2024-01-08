include <submodules/BOSL2/std.scad>
include <submodules/BOSL2/beziers.scad>

/* [Hidden] */
$fn=32;

/* [Рукоятка] */

// Длина рукоятки
handle_length = 130;

// Большой диаметр рукоятки
handle_major_diameter = 55;

// Малый диаметр рукоятки
handle_minor_diameter = 35;

// Параметр для утончения рукоятки
handle_spline_control  = 0;

// Толщина стенки вспомогательной трубы
support_thickness = 1.0;

// Диаметр трубы ПВХ
pvc_tube_diameter = 26;

/* [Заклепки] */

// Расстояние между заклепками
stud_spacing = 50;

// Длина заклепок
stud_length = 8;

// Диаметр заклепок
stud_diameter = 5;

// Диаметр шарика-фиксатора
stud_ball_diameter = 12;

// Удлинение заклепки
stud_extension = 1.0;

/* [Яблоко] */

// Большой диаметр яблока
apple_major_diameter = 85;

// Малый диаметр яблока
apple_minor_diameter = 50;

// Диаметр скругления яблока
apple_fillet_diameter = 20;

// Диаметр посадочного места под болт
bolt_head_diameter = 35;

// Толщина площадки под головку болта
bolt_head_thickness = 13;

/* [Коэффициенты размеров] */

// Коэффициент конусности затычки яблока
plug_cone_factor = 0.8;

// Коэффициент размера затычки яблока
plug_size_factor = 1.05;

// Коэффициент размера заклепок
stud_size_factor = 1.1;

/* [Генерация модели] */

// тип модели
model_type = 1; // [1:Рукоятка, 2:Яблоко, 3:Затычка, 4:Сборка, 5:Отладка]

module raw_handle() {
  path = [
          [0, -handle_length/2],
          each bezier_curve([
                             [handle_major_diameter/2,-handle_length/2],
                             [handle_spline_control/2, 0],
                             [handle_major_diameter/2, handle_length/2]]),
          [0, handle_length/2]];
  difference() {
    yscale(handle_minor_diameter/handle_major_diameter)
      up(handle_length/2)
      rotate_sweep(path, closed=false, style="convex");
    cylinder(h = handle_length, d = pvc_tube_diameter);
  }
}

module raw_handle_1() {
  zstep = 5;
  narrowing_x = 0.6;
  narrowing_y = 0.6;
  difference() {
    union() {
      for (z = [0:zstep:handle_length-zstep]) {
        factor = (z - handle_length/2)/(handle_length/2);
        scale_x = narrowing_x*(1-factor^2) + factor^2;
        scale_y = narrowing_y*(1-factor^2) + factor^2;
        p1 = xscale(scale_x,
                    yscale(scale_y,
                           yscale(handle_minor_diameter/handle_major_diameter,
                                  p = circle(d = handle_major_diameter))));
        z1 = z + zstep;
        factor1 = (z1 - handle_length/2)/(handle_length/2);
        scale_x1 = narrowing_x*(1-factor1^2) + factor1^2;
        scale_y1 = narrowing_y*(1-factor1^2) + factor1^2;
        p2 = xscale(scale_x1,
                    yscale(scale_y1,
                           yscale(handle_minor_diameter/handle_major_diameter,
                                  p = circle(d = handle_major_diameter))));
        skin([p1, p2], z = [z, z1], slices = 3);
      }
    }
    cylinder(h = handle_length, d = pvc_tube_diameter);
  }
}

module raw_studs(factor = 1.0, extend = 0.0) {
  zflip()
    xcopies(stud_spacing, 2)
    scale([factor, factor, 1])
    cylinder(h = stud_length + extend, d = stud_diameter) {
    position(TOP) sphere(d = stud_ball_diameter, anchor = CENTER);
    }
}

module sword_handle() {
  union() {
    raw_handle_1();
    raw_studs();
    tube(h = handle_length,
         id = pvc_tube_diameter,
         wall = support_thickness,
         anchor = BOTTOM);
  }
}

module raw_apple() {
  pts = [each fwd(apple_fillet_diameter/2,
                  [
                   each arc($fn, d = apple_major_diameter, angle = [-90, 0]),
                   each right((apple_major_diameter - apple_fillet_diameter)/2,
                              arc($fn, d = apple_fillet_diameter, angle = [0, 90]))]),
         [0, 0]];
  yscale(apple_minor_diameter/apple_major_diameter)
    rotate_sweep(pts);
}

module raw_plug() {
  zflip()
    up(2*bolt_head_thickness)
    cylinder(h = apple_major_diameter/2 + apple_fillet_diameter/2 - bolt_head_thickness,
             d1 = 1.2*bolt_head_diameter,
             d2 = 1.2*bolt_head_diameter * plug_cone_factor);
}

module sword_apple() {
  difference() {
    raw_apple();

    zflip()
      cylinder(h = apple_major_diameter, d = pvc_tube_diameter);
    down(bolt_head_thickness)
    zflip()
      cylinder(h = bolt_head_thickness, d = bolt_head_diameter);

    raw_studs(factor = stud_size_factor,
              extend = stud_extension);
    raw_plug();
  }
}

module sword_plug() {
  intersection() {
    bottom_half(z = -(bolt_head_thickness*2))
    raw_apple();
    scale([plug_size_factor, plug_size_factor, 1])
      raw_plug();
  }
}

if (model_type == 1)
  sword_handle();
 else if (model_type == 2)
   sword_apple();
 else if (model_type == 3)
   sword_plug();
 else if (model_type == 4) {
   back_half() {
     sword_apple();
   }
   sword_handle();
   sword_plug();
 }
