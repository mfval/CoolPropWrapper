% martinRunner

V_SI = (5E-4:1E-7:0.04);    %[kg/m3]

figure,
for T_SI = 5:20:165
    MartinHou_EOS;
    semilogy(V_SI,P_SI.*convert('pa','kpa'),'DisplayName',num2str(T_SI)), hold on;
end
ylim([5E-1,5E3]), xlim([V_SI(1), V_SI(end)])
legend('show')
plot(vc*convert('ft3/lbm', 'm3/kg'), Pc*convert('psia','kPa'),'s');

hold on,
plot(EES_data(:,1), EES_data(:,2)*convert('Pa','kPa'),'.')