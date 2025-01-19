#include <iostream>
#include <set>
extern "C" double Lagrange(const double* x_values, const double* y_values, int n, double x, double* coefficients, double* basisPolynomials);
using namespace std;
/*
// Функция для вычисления базисных полиномов L_i(x)
void computeBasisPolynomials(const double* x_values, int n, double x, double* basisPolynomials) 
{
	for (int i = 0; i < n; ++i) 
	{
		double L_i = 1.0;
		for (int j = 0; j < n; ++j) 
		{
			if (i != j) {
				L_i *= (x - x_values[j]) / (x_values[i] - x_values[j]);
			}
		}
		basisPolynomials[i] = L_i;
	}
}

// Функция для расчета полинома Лагранжа
double Lagrange(const double* x_values,	const double* y_values,	int n,	double x,	double* coefficients,	double* basisPolynomials)
{

	// Вычисление базисных полиномов
	computeBasisPolynomials(x_values, n, x, basisPolynomials);

	// Вычисление значения полинома в точке x
	double polynomialValue = 0.0;
	double pol2[2];
	double *pol1 = new double[n];
	for (int i = 0; i < n; ++i) {
		polynomialValue += y_values[i] * basisPolynomials[i];
	}

	double *C = new double[n];
	for (int i = 0; i < n; i++)
	{
		coefficients[i] = 0;
	}

	// Вычисление коэффициентов полинома
	for (int i = 0; i < n; ++i) 
	{
		for (int j = 0; j < n; j++)
		{
			C[j] = 0;
		}
		C[0] = 1;
		double denominator = 1.0;
		for (int j = 0; j < n; ++j) 
		{
			if (j != i) 
			{
				pol2[1] = 1;
				pol2[0] = -x_values[j];
				for (int z = 0; z < n; z++)
				{
					pol1[z] = C[z];
				}
				//умножение
				for (int k = 0; k < n; k++)
				{
					C[k] = 0;
				}
				for (int k = 0; k < n-1; k++)
				{
					for (int p = 0; p < 2; p++)
					{
						C[k + p] += pol1[k] * pol2[p];
					}
				}


				denominator *= (x_values[i] - x_values[j]);
			}
		}
		for (int j = 0; j < n; j++)
		{
			C[j] *= y_values[i] / denominator;
			coefficients[j] += C[j];
		}

	}
	return polynomialValue;
}
*/
//Проверка значений
bool check(double *x_values, int n, double x)
{
	set<double> s;
	double min = x_values[0];
	double max = x_values[0];
	for (int i = 0; i < n; i++)
	{
		s.insert(x_values[i]);
		if (x_values[i] < min)
		{
			min = x_values[i];
		}
		if (x_values[i] > max)
		{
			max = x_values[i];
		}
	}
	if (s.size() < n || x<min||x>max)	//если есть неуникальные значения или х выходит за границы диапазона
		return false;		//то проверка не пройдена
	return true;

}
int main()
{
	/*
	int n = 6;
	double x_values[] = { 10,20,30,40,50,60 };   //исходные данные для вычисления интерполяционного многочлена Лагранжа
	double y_values[] = { 0.17365, 0.34202, 0.5, 0.64279, 0.76604, 0.86603 };
	double x = 23;
	*/
	/*
	int n = 3;
	double x_values[] = { 1, 2, 3 };
	double y_values[] = { 2, 3, 5 };
	double x = 2.5;
	*/
	setlocale(LC_ALL, "Russian");//русская локаль

	int n;
	cout << "n = ";
	cin >> n;
	if (n < 2)
	{
		cout << "Количество точек должно быть больше одной" << endl;
		system("pause");
		return 0;
	}
	double *x_values = new double[n];
	double *y_values = new double[n];
	for (int i = 0; i < n; i++)
	{
		cout << "X[" << i + 1 << "] = ";
		cin >> x_values[i];
		cout << "Y[" << i + 1 << "] = ";
		cin >> y_values[i];
	}
	double x;
	cout << "x = ";
	cin >> x;
	
	if(!check(x_values,n,x))
	{
		cout << "В массиве x есть неуникальные значения или х выходит за границы диапазона" << endl;
		system("pause");
		return 0;
	}

	double *coefficients=new double[n];       // Массив для коэффициентов полинома
	double *basisPolynomials= new double[n];   // Массив для базисных полиномов

	// Вызов функции
	double polynomialValue = Lagrange(x_values, y_values, n, x, coefficients, basisPolynomials);
	//Вывод результата
	cout << "Коэффициенты полинома Лагранжа(от меньей степени, к большей):" << endl;
	for (int i = 0; i < n; ++i) 
	{
		cout << coefficients[i] << "\t";
	}
	cout << endl << "Значение полинома в точке " << x << ": " << polynomialValue << endl;

	cout << "Базисные полиномы:\n";
	for (int i = 0; i < n; ++i) 
	{
		cout << basisPolynomials[i] << "\t";
	}
	cout << endl;

	double result = 0.0;
	double x_power = 1.0; // Для хранения текущей степени x (x^i)
	// по схеме Горнера вычисляется значение полинома
	for (int i = 0; i < n; ++i) {
		result += coefficients[i] * x_power; // Добавляем a_i * x^i
		x_power *= x; // Увеличиваем степень x
	}

	cout << "\nЗначение полинома в точке " << x << " по значениям коэффициентов полинома: " << result << "\n";
	delete[] coefficients;
	delete[] basisPolynomials;
	system("pause");
	return 0;
}