#include "pch.h"
#include"functions1.hpp"
#include "MyForm.h"

using namespace System;
using namespace System::Windows::Forms;

[STAThread]// openfile dialog icin thread
int main() {
	Application::EnableVisualStyles();
	Application::SetCompatibleTextRenderingDefault(false);
	ui11::MyForm main_form;
	Application::Run(% main_form);
	return 0;
}
