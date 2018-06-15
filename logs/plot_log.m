log_data = table2array(modeltrain);

subplot(1,2,1)
plot(log_data(2:2:end,1), log_data(2:2:end,4))
grid on
grid minor
xlabel('Num. iters')
ylabel('Accuracy')

subplot(1,2,2)
plot(log_data(2:2:end,1), log_data(2:2:end,5))
grid on
grid minor
xlabel('Num. iters')
ylabel('Loss')
