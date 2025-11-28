% 数据定义
d = [5.26  5.19  4.21  4.00  2.95  2.74  2.46  1.90  0.64  1.27;
     1.90  0.99  1.90  1.13  1.27  2.25  1.48  2.04  3.09  3.51;
     4.42  3.86  3.72  3.16  2.25  2.81  0.78  1.62  1.27  0.50;
     5.89  5.61  5.61  4.56  3.51  3.65  2.46  2.46  1.06  0.57;
     0.64  1.76  1.27  1.83  2.74  2.60  4.21  3.72  5.05  6.10];

n = [0   13   0    0    0    0    0   54    0   11;
     0   42   0   43    0    0    0    0    0    0;
     0   13   2    0    0    0    0    0    0   70;
     0    0   0    0    0    0    0    0   70   15;
     81   0  43    0    0    0    0    0    0    0];

[num_rows, num_cols] = size(n);

% 计算 T(i,j) = 8 + 2*(60/28)*d(i,j)
T = 8 + 2 * (60/28) * d;

% 计算 F(i,j) = floor(480/T(i,j))
F = floor(480 ./ T);

% 创建优化变量 A
A = optimvar('A', num_rows, num_cols, 'Type', 'integer', 'LowerBound', 0);

% 创建优化问题
prob = optimproblem('Objective', sum(A(:)));

% 添加约束：A(i,j) * F(i,j) >= n(i,j)
for i = 1:num_rows
    for j = 1:num_cols
        if n(i,j) > 0  % 只为非零的n(i,j)添加约束
            prob.Constraints.(['capacity_' num2str(i) '_' num2str(j)]) = ...
                A(i,j) * F(i,j) >= n(i,j);
        else
            % 如果n(i,j)=0，A(i,j)可以为0，但不需要显式约束
            % 因为下界已经是0
        end
    end
end

% 求解问题
[sol, fval] = solve(prob);

% 输出结果
fprintf('%.0f\n', fval);
disp(sol.A);