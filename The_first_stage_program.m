% 数据定义
d = [5.26  5.19  4.21  4.00  2.95  2.74  2.46  1.90  0.64  1.27;
     1.90  0.99  1.90  1.13  1.27  2.25  1.48  2.04  3.09  3.51;
     4.42  3.86  3.72  3.16  2.25  2.81  0.78  1.62  1.27  0.50;
     5.89  5.61  5.61  4.56  3.51  3.65  2.46  2.46  1.06  0.57;
     0.64  1.76  1.27  1.83  2.74  2.60  4.21  3.72  5.05  6.10];

Q = [12000 13000 13000 13000 19000];
y = [0.30 0.28 0.29 0.32 0.31 0.33 0.32 0.31 0.33 0.31];
S_ore = [9500 10500 10000 10500 11000 12500 10500 13000 13500 12500];
S_rock = [12500 11000 13500 10500 11500 13500 10500 11500 13500 12500];

num_unload = 5;
num_shovel = 10;

% 创建优化变量
n = optimvar('n', num_unload, num_shovel, 'Type', 'integer', 'LowerBound', 0);
z = optimvar('z', num_shovel, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);

% 创建优化问题
prob = optimproblem('Objective', sum(n(:) .* d(:)));

% 品位约束
for i = 1:3
    prob.Constraints.(['grade_low_' num2str(i)]) = sum(n(i,:) .* (y - 0.285)) >= 0;
    prob.Constraints.(['grade_high_' num2str(i)]) = sum(n(i,:) .* (y - 0.305)) <= 0;
end

% 产量约束
for i = 1:num_unload
    prob.Constraints.(['production_' num2str(i)]) = 154 * sum(n(i,:)) >= Q(i);
end

% 矿石产量约束
for j = 1:num_shovel
    prob.Constraints.(['ore_production_' num2str(j)]) = 154 * sum(n(1:3,j)) <= S_ore(j);
end

% 岩石产量约束
for j = 1:num_shovel
    prob.Constraints.(['rock_production_' num2str(j)]) = 154 * sum(n(4:5,j)) <= S_rock(j);
end

% 最多使用7个铲位
prob.Constraints.max_shovels = sum(z) <= 7;

% 铲位使用约束
for j = 1:num_shovel
    prob.Constraints.(['shovel_use_' num2str(j)]) = sum(n(:,j)) <= 96 * z(j);
end

% 卸点工作次数约束
for i = 1:num_unload
    prob.Constraints.(['unload_work_' num2str(i)]) = sum(n(i,:)) <= 160;
end

% 总时间约束
prob.Constraints.total_time = 8 * sum(n(:)) + 2 * (60/28) * sum(n(:) .* d(:)) <= 9600;

% 求解问题
[sol, fval] = solve(prob);

% 输出结果
disp(fval);

disp(sol.n);


disp(sol.z);
