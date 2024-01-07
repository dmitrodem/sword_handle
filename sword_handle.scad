include <BOSL2/std.scad>
include <BOSL2/beziers.scad>

/* [Hidden] */
$fn=32;

/* [Рукоятка] */

// Длина рукоятки
handle_length = 130;

// Большой диаметр рукоятки
handle_major_diameter = 65;

// Малый диаметр рукоятки
handle_minor_diameter = 30;

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
stud_length = 30;

// Диаметр заклепок
stud_diameter = 8;

// Диаметр шарика-фиксатора
stud_ball_diameter = 12;

// Удлинение заклепки
stud_extension = 3.0;

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
bolt_head_thickness = 10;

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
    raw_handle();
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
    up(bolt_head_thickness)
    cylinder(h = apple_major_diameter/2 + apple_fillet_diameter/2 - bolt_head_thickness,
             d1 = bolt_head_diameter,
             d2 = bolt_head_diameter * plug_cone_factor);
}

module sword_apple() {
  difference() {
    raw_apple();

    zflip()
      cylinder(h = apple_major_diameter, d = pvc_tube_diameter);
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
 } else {
   difference() {
     right(stud_spacing/2)
       cuboid(size = [20, 20, 40], rounding = 5, except = [TOP, BOTTOM], anchor = TOP);
     raw_studs(1.1, extend = 3.0);
   }
 }
