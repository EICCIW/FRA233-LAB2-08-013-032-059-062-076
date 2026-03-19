% =========================================================
% คำนวณค่า a, b สำหรับ Forward, Backward และ Tustin (2nd Order)
% =========================================================
clear; clc; close all;

%% 1. กำหนดพารามิเตอร์มอเตอร์ (ของจริง)
Ts = 0.001;                 % Sampling Time = 1 ms 
kt = 0.0473;
ke = 0.0473;
Lm = 0.003384;
R  = 5.52186;
b  = 0.000023653;
J  = 0.00001307;

% สร้าง Continuous Model (s-domain) เป็น Second Order แบบสมบูรณ์
s = tf('s');
plant_s = minreal(kt / ((Lm*s + R)*(J*s + b) + kt*ke));

%% 2. กำหนดตัวแปร z สำหรับการแทนค่า
z = tf('z', Ts);

%% 3. คำนวณวิธีที่ 1: Forward Euler
s_fw = (z - 1) / Ts;
sys_fw = minreal(kt / ((Lm*s_fw + R)*(J*s_fw + b) + kt*ke));
[num_fw, den_fw] = tfdata(sys_fw, 'v');
% ป้องกันกรณีที่ MATLAB ตัดสัมประสิทธิ์ที่เป็น 0 ทิ้ง ให้เติม 0 ให้ครบ 3 ตำแหน่ง (2nd Order)
num_fw = [zeros(1, 3-length(num_fw)), num_fw]; 
den_fw = [zeros(1, 3-length(den_fw)), den_fw];
num_fw = num_fw / den_fw(1);    % ทำให้ a0 = 1 เสมอ
den_fw = den_fw / den_fw(1);

%% 4. คำนวณวิธีที่ 2: Backward Euler
s_bw = (z - 1) / (z * Ts);
sys_bw = minreal(kt / ((Lm*s_bw + R)*(J*s_bw + b) + kt*ke));
[num_bw, den_bw] = tfdata(sys_bw, 'v');
num_bw = [zeros(1, 3-length(num_bw)), num_bw];
den_bw = [zeros(1, 3-length(den_bw)), den_bw];
num_bw = num_bw / den_bw(1);
den_bw = den_bw / den_bw(1);

%% 5. คำนวณวิธีที่ 3: Tustin (Bilinear)
sys_tu = c2d(plant_s, Ts, 'tustin');
[num_tu, den_tu] = tfdata(sys_tu, 'v');
num_tu = [zeros(1, 3-length(num_tu)), num_tu];
den_tu = [zeros(1, 3-length(den_tu)), den_tu];
num_tu = num_tu / den_tu(1);
den_tu = den_tu / den_tu(1);

%% 6. ปริ้นท์ผลลัพธ์เพื่อนำไปใส่ใน C Code
fprintf('// ====================================\n');
fprintf('// 1. FORWARD EULER (2nd Order)\n');
fprintf('// ====================================\n');
fprintf('float a1_fw = %f;\n', den_fw(2));
fprintf('float a2_fw = %f;\n', den_fw(3));
fprintf('float b0_fw = %f;\n', num_fw(1));
fprintf('float b1_fw = %f;\n', num_fw(2));
fprintf('float b2_fw = %f;\n\n', num_fw(3));

fprintf('// ====================================\n');
fprintf('// 2. BACKWARD EULER (2nd Order)\n');
fprintf('// ====================================\n');
fprintf('float a1_bw = %f;\n', den_bw(2));
fprintf('float a2_bw = %f;\n', den_bw(3));
fprintf('float b0_bw = %f;\n', num_bw(1));
fprintf('float b1_bw = %f;\n', num_bw(2));
fprintf('float b2_bw = %f;\n\n', num_bw(3));

fprintf('// ====================================\n');
fprintf('// 3. TUSTIN (BILINEAR) (2nd Order)\n');
fprintf('// ====================================\n');
fprintf('float a1_tu = %f;\n', den_tu(2));
fprintf('float a2_tu = %f;\n', den_tu(3));
fprintf('float b0_tu = %f;\n', num_tu(1));
fprintf('float b1_tu = %f;\n', num_tu(2));
fprintf('float b2_tu = %f;\n\n', num_tu(3));

%% 7. พล็อตกราฟเปรียบเทียบ (s-domain vs z-domain)
figure('Color', 'w', 'Name', '2nd Order Discretization Comparison', 'Position', [100 100 800 500]);
% พล็อต Continuous (อุดมคติ) เป็นเส้นทึบสีดำ
step(plant_s * 12, 0.5); hold on;

% พล็อต Discrete ทั้ง 3 วิธี (MATLAB จะวาดเป็นขั้นบันไดให้โดยอัตโนมัติ)
step(sys_fw * 12, 0.5, 'r--'); 
step(sys_bw * 12, 0.5, 'g--');
step(sys_tu * 12, 0.5, 'b--');

title('Step Response Comparison: 2nd Order Motor Model (12V Input)');
xlabel('Time (seconds)');
ylabel('Speed (rad/s)');
legend('Continuous (Ideal)', 'Forward Euler', 'Backward Euler', 'Tustin', 'Location', 'best');
grid on;