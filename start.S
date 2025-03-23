.syntax unified       // Використання єдиного синтаксису Thumb/ARM
.cpu cortex-m4        // Вказуємо архітектуру процесора Cortex-M4
//.fpu softvfp        // Вимкнене програмне керування FPU (закоментовано)
.thumb               // Використання Thumb-інструкцій

// Оголошення глобальних міток, які можуть використовуватися в інших файлах
.global vtable
.global __hard_reset__

/*
 * Таблиця векторів переривань (vector table)
 */
.type vtable, %object
vtable:
    .word __stack_start  // Початкова адреса стеку
    .word __hard_reset__+1  // Початкова точка входу (біт 0 = 1 для режиму Thumb)
.size vtable, .-vtable

// Функція апаратного скидання (Hard Reset)
__hard_reset__:
    ldr r0, =__stack_start  // Завантажуємо адресу початку стеку в r0
    mov sp, r0              // Встановлюємо стековий вказівник (SP)
    b __hard_reset__        // Безкінечний цикл (неправильний код, варто додати обробку)
