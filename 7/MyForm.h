#include"functions1.hpp"
namespace ui11 {
	
	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;
	//using namespace imp;
	/// <summary>
	/// MyForm için özet
	/// </summary>
	public ref class MyForm : public System::Windows::Forms::Form
	{
	private: System::Windows::Forms::Label^ label8;
	private: System::Windows::Forms::TextBox^ textBox6;
	private: System::Windows::Forms::ToolStripMenuItem^ histogramEqualizeToolStripMenuItem;
	public:	
		imp::Image* img;
		Bitmap^ bmp;
		int channel = 3;
		bool first = true;
		System::String^ basePath = "C:\\Users\\user\\Desktop\\samples\\";//"C:\\Users\\user\\PycharmProjects\\derinogrenme\\okey_tasi2\\"
		std::string stringToString(System::String^ s) {//max 150 character
			char cStr[150] = { 0 };			
			if (s->Length < sizeof(cStr))
				sprintf(cStr, "%s", s);
			std::string ss(cStr);
			return ss;
		}		
		void bitmapToImage() {
			int h = this->bmp->Height;
			int w = this->bmp->Width;
			Drawing::Color clr;
			unsigned char r, g, b;
			//if this is the first time, img data has not allocated yet!
			if (!this->first) {//?
				free(this->img->data);
			}				
			this->img->height = h;
			this->img->width = w;
			if (this->channel == 3) {
				this->img->channel = 3;
				this->img->data = (float*)malloc(sizeof(float) * h * w * 3);
				for (int i = 0; i < h; i++) {
					for (int j = 0; j < w; j++) {
						clr = this->bmp->GetPixel(j, i);
						r = clr.R;
						g = clr.G;
						b = clr.B;
						this->img->data[(i * w + j) * 3 + 0] = (float)r;
						this->img->data[(i * w + j) * 3 + 1] = (float)g;
						this->img->data[(i * w + j) * 3 + 2] = (float)b;
					}
				}
			}
			else if (this->channel == 1) {
				this->img->channel = 1;
				this->img->data = (float*)malloc(sizeof(float) * h * w);
				for (int i = 0; i < h; i++) {
					for (int j = 0; j < w; j++) {
						clr = this->bmp->GetPixel(j, i);
						r = clr.R;
						g = clr.G;
						b = clr.B;
						this->img->data[i * w + j] = (float)r;						
					}
				}
			}
		}
		void imageToBitmap() {
			int h = this->img->height;
			int w = this->img->width;
			this->channel = this->img->channel;
			Drawing::Color clr;			
			unsigned char r, g, b;			
			this->bmp = gcnew Bitmap(this->bmp, w, h);
			if (this->channel == 3) {								
				for (int i = 0; i < h; i++) {
					for (int j = 0; j < w; j++) {						
						r = (unsigned char)this->img->data[(i * w + j) * 3 + 0];
						g = (unsigned char)this->img->data[(i * w + j) * 3 + 1];
						b = (unsigned char)this->img->data[(i * w + j) * 3 + 2];						
						clr = System::Drawing::Color::FromArgb(255,r,g,b);
						this->bmp->SetPixel(j, i, clr);
					}
				}
			}
			else if (this->channel == 1) {								
				for (int i = 0; i < h; i++) {
					for (int j = 0; j < w; j++) {
						clr = this->bmp->GetPixel(j, i);
						r = (unsigned char)this->img->data[i * w + j];						
						clr = System::Drawing::Color::FromArgb(255, r, r, r);
						this->bmp->SetPixel(j, i, clr);
					}
				}
			}
		}
		void readImage(System::String^ s) {		
			this->bmp = gcnew Bitmap(s);
			this->pictureBox1->Image = this->bmp;
			this->bitmapToImage();
			this->refreshSizeLabel();
			if (this->first) {//?
				this->first = false;
			}
		}
		void writeImage(System::String^ s) {
			//kaydetmeden r ve b kanallarinin yerlerini degistir!
			imp::writeImage(*this->img, stringToString(s));
		}	
		void refreshSizeLabel() {
			System::String^ s;
			System::String^ s2;
			s = Convert::ToString(this->img->height);
			s2 = Convert::ToString(this->img->width);
			System::String^ s3 = s + "," + s2;
			this->label6->Text = s3;
		}
		void refreshScreen() {			
			this->imageToBitmap();			
			this->pictureBox1->Image = this->bmp;
			this->refreshSizeLabel();
		}
		void convertToGray() {
			*this->img=imp::convertToGray(*this->img);		
			this->channel = 1;
		}
		void resizeImage() {
			int h, w;			
			System::String^ s=this->textBox1->Text;
			cli::array<System::String^>^ ss = s->Split(',');
			h = Convert::ToInt32(ss[0]);
			w = Convert::ToInt32(ss[1]);
			*this->img= imp::resizeImage(*this->img, h, w);			
		}	
		void cutImage() {
			int x1, y1, x2, y2;
			System::String^ s = this->textBox2->Text;
			cli::array<System::String^>^ ss = s->Split(',');
			x1 = Convert::ToInt32(ss[0]);
			y1 = Convert::ToInt32(ss[1]);
			x2 = Convert::ToInt32(ss[2]);
			y2 = Convert::ToInt32(ss[3]);					
			*this->img = imp::cutImage(*this->img, y1, x1, y2, x2);			
		}
		void thresholdBinary() {
			int th;
			System::String^ s = this->textBox6->Text;			
			th = Convert::ToInt32(s);
			*this->img = imp::thresholdBinary(*this->img, th);
		}
		void threshOtsu() {
			int th = (int) imp::otsuThresh(*this->img);
			*this->img = imp::thresholdBinary(*this->img, th);
		}
		void smoothing() {
			int fH;
			System::String^ s = this->textBox3->Text;
			fH = Convert::ToInt32(s);
			*this->img = imp::smoothing(*this->img, fH);
		}
		void sharpening() {
			int fH;
			System::String^ s = this->textBox3->Text;
			fH = Convert::ToInt32(s);
			*this->img = imp::sharpening(*this->img, fH);
		}
		void edgeDetection() {			
			*this->img = imp::edgeDetection(*this->img);
		}
		void laplacian() {			
			*this->img = imp::laplacian(*this->img);
		}
		void dilation() {
			int fH,se;
			System::String^ s = this->textBox3->Text;			
			fH = Convert::ToInt32(s);
			s = this->textBox5->Text;
			se = Convert::ToInt32(s);
			*this->img = imp::morpDilation(*this->img,fH,se);
		}
		void erode() {
			int fH, se;
			System::String^ s = this->textBox3->Text;
			fH = Convert::ToInt32(s);
			s = this->textBox5->Text;
			se = Convert::ToInt32(s);
			*this->img = imp::morpErode(*this->img, fH, se);
		}
		void opening() {
			int fH, se;
			System::String^ s = this->textBox3->Text;
			fH = Convert::ToInt32(s);
			s = this->textBox5->Text;
			se = Convert::ToInt32(s);
			*this->img = imp::morpOpen(*this->img, fH, se);
		}
		void closing() {
			int fH, se;
			System::String^ s = this->textBox3->Text;
			fH = Convert::ToInt32(s);
			s = this->textBox5->Text;
			se = Convert::ToInt32(s);
			*this->img = imp::morpClose(*this->img, fH, se);
		}
		void reverse() {
			*this->img = imp::reverseImage(*this->img);
		}
		void kmeans() {
			int k;
			System::String^ s = this->textBox4->Text;
			k = Convert::ToInt32(s);			
			*this->img = imp::kmeansCluster(*this->img, k);
		}	
		void histEqual() {
			*this->img = imp::histogramEqual(*this->img);
		}
		void connComp() {
			*this->img = imp::connectedComponents(*this->img);
		}
		MyForm(void){			
			InitializeComponent();	
			this->img = (imp::Image*)malloc(sizeof(imp::Image));			
			
		}
	protected:		
		~MyForm()
		{
			if (components)
			{
				delete components;
			}
		}
	private: System::Windows::Forms::PictureBox^ pictureBox1;
	private: System::Windows::Forms::MenuStrip^ menuStrip1;
	private: System::Windows::Forms::ToolStripMenuItem^ fileToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ openToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ saveToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ preProcessToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ resizeToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ cutToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ rGB2GRAYToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ thresholdToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ otsuThresholdToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ filterProcessToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ smToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ sharpeningToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ edgeDetectionToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ laplacianFilterToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ blackWhiteProcessToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ dilationToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ eroziToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ openingToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ closingToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ extrasToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ kmeansToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ connectedComponentsToolStripMenuItem;
	private: System::Windows::Forms::ToolStripMenuItem^ reverseToolStripMenuItem;
	private: System::Windows::Forms::Label^ label1;
	private: System::Windows::Forms::Label^ label2;
	private: System::Windows::Forms::Label^ label3;
	private: System::Windows::Forms::Label^ label4;
	private: System::Windows::Forms::Label^ label5;
	private: System::Windows::Forms::TextBox^ textBox1;
	private: System::Windows::Forms::TextBox^ textBox2;
	private: System::Windows::Forms::TextBox^ textBox3;
	private: System::Windows::Forms::TextBox^ textBox4;
	private: System::Windows::Forms::TextBox^ textBox5;
	private: System::Windows::Forms::Label^ label6;
	private: System::Windows::Forms::Label^ label7;
	protected:

	private:
		/// <summary>
		///Gerekli tasarýmcý deðiþkeni.
		/// </summary>
		System::ComponentModel::Container^ components;

#pragma region Windows Form Designer generated code
		/// <summary>
		/// Tasarýmcý desteði için gerekli metot - bu metodun 
		///içeriðini kod düzenleyici ile deðiþtirmeyin.
		/// </summary>
		void InitializeComponent(void)
		{
			this->pictureBox1 = (gcnew System::Windows::Forms::PictureBox());
			this->menuStrip1 = (gcnew System::Windows::Forms::MenuStrip());
			this->fileToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->openToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->saveToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->preProcessToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->resizeToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->cutToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->rGB2GRAYToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->thresholdToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->otsuThresholdToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->filterProcessToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->smToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->sharpeningToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->edgeDetectionToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->laplacianFilterToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->blackWhiteProcessToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->dilationToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->eroziToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->openingToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->closingToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->reverseToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->extrasToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->kmeansToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->connectedComponentsToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->histogramEqualizeToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->label1 = (gcnew System::Windows::Forms::Label());
			this->label2 = (gcnew System::Windows::Forms::Label());
			this->label3 = (gcnew System::Windows::Forms::Label());
			this->label4 = (gcnew System::Windows::Forms::Label());
			this->label5 = (gcnew System::Windows::Forms::Label());
			this->textBox1 = (gcnew System::Windows::Forms::TextBox());
			this->textBox2 = (gcnew System::Windows::Forms::TextBox());
			this->textBox3 = (gcnew System::Windows::Forms::TextBox());
			this->textBox4 = (gcnew System::Windows::Forms::TextBox());
			this->textBox5 = (gcnew System::Windows::Forms::TextBox());
			this->label6 = (gcnew System::Windows::Forms::Label());
			this->label7 = (gcnew System::Windows::Forms::Label());
			this->label8 = (gcnew System::Windows::Forms::Label());
			this->textBox6 = (gcnew System::Windows::Forms::TextBox());
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->pictureBox1))->BeginInit();
			this->menuStrip1->SuspendLayout();
			this->SuspendLayout();
			// 
			// pictureBox1
			// 
			this->pictureBox1->Location = System::Drawing::Point(138, 135);
			this->pictureBox1->Name = L"pictureBox1";
			this->pictureBox1->Size = System::Drawing::Size(600, 405);
			this->pictureBox1->TabIndex = 0;
			this->pictureBox1->TabStop = false;
			// 
			// menuStrip1
			// 
			this->menuStrip1->Items->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(5) {
				this->fileToolStripMenuItem,
					this->preProcessToolStripMenuItem, this->filterProcessToolStripMenuItem, this->blackWhiteProcessToolStripMenuItem, this->extrasToolStripMenuItem
			});
			this->menuStrip1->Location = System::Drawing::Point(0, 0);
			this->menuStrip1->Name = L"menuStrip1";
			this->menuStrip1->Size = System::Drawing::Size(1050, 24);
			this->menuStrip1->TabIndex = 2;
			this->menuStrip1->Text = L"menuStrip1";
			// 
			// fileToolStripMenuItem
			// 
			this->fileToolStripMenuItem->DropDownItems->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(2) {
				this->openToolStripMenuItem,
					this->saveToolStripMenuItem
			});
			this->fileToolStripMenuItem->Name = L"fileToolStripMenuItem";
			this->fileToolStripMenuItem->Size = System::Drawing::Size(37, 20);
			this->fileToolStripMenuItem->Text = L"File";
			// 
			// openToolStripMenuItem
			// 
			this->openToolStripMenuItem->Name = L"openToolStripMenuItem";
			this->openToolStripMenuItem->Size = System::Drawing::Size(103, 22);
			this->openToolStripMenuItem->Text = L"Open";
			this->openToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::openToolStripMenuItem_Click);
			// 
			// saveToolStripMenuItem
			// 
			this->saveToolStripMenuItem->Name = L"saveToolStripMenuItem";
			this->saveToolStripMenuItem->Size = System::Drawing::Size(103, 22);
			this->saveToolStripMenuItem->Text = L"Save";
			this->saveToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::saveToolStripMenuItem_Click);
			// 
			// preProcessToolStripMenuItem
			// 
			this->preProcessToolStripMenuItem->DropDownItems->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(5) {
				this->resizeToolStripMenuItem,
					this->cutToolStripMenuItem, this->rGB2GRAYToolStripMenuItem, this->thresholdToolStripMenuItem, this->otsuThresholdToolStripMenuItem
			});
			this->preProcessToolStripMenuItem->Name = L"preProcessToolStripMenuItem";
			this->preProcessToolStripMenuItem->Size = System::Drawing::Size(79, 20);
			this->preProcessToolStripMenuItem->Text = L"Pre Process";
			// 
			// resizeToolStripMenuItem
			// 
			this->resizeToolStripMenuItem->Name = L"resizeToolStripMenuItem";
			this->resizeToolStripMenuItem->Size = System::Drawing::Size(154, 22);
			this->resizeToolStripMenuItem->Text = L"Resize";
			this->resizeToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::resizeToolStripMenuItem_Click);
			// 
			// cutToolStripMenuItem
			// 
			this->cutToolStripMenuItem->Name = L"cutToolStripMenuItem";
			this->cutToolStripMenuItem->Size = System::Drawing::Size(154, 22);
			this->cutToolStripMenuItem->Text = L"Cut";
			this->cutToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::cutToolStripMenuItem_Click);
			// 
			// rGB2GRAYToolStripMenuItem
			// 
			this->rGB2GRAYToolStripMenuItem->Name = L"rGB2GRAYToolStripMenuItem";
			this->rGB2GRAYToolStripMenuItem->Size = System::Drawing::Size(154, 22);
			this->rGB2GRAYToolStripMenuItem->Text = L"RGB2GRAY";
			this->rGB2GRAYToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::rGB2GRAYToolStripMenuItem_Click);
			// 
			// thresholdToolStripMenuItem
			// 
			this->thresholdToolStripMenuItem->Name = L"thresholdToolStripMenuItem";
			this->thresholdToolStripMenuItem->Size = System::Drawing::Size(154, 22);
			this->thresholdToolStripMenuItem->Text = L"Threshold";
			this->thresholdToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::thresholdToolStripMenuItem_Click);
			// 
			// otsuThresholdToolStripMenuItem
			// 
			this->otsuThresholdToolStripMenuItem->Name = L"otsuThresholdToolStripMenuItem";
			this->otsuThresholdToolStripMenuItem->Size = System::Drawing::Size(154, 22);
			this->otsuThresholdToolStripMenuItem->Text = L"Otsu Threshold";
			this->otsuThresholdToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::otsuThresholdToolStripMenuItem_Click);
			// 
			// filterProcessToolStripMenuItem
			// 
			this->filterProcessToolStripMenuItem->DropDownItems->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(4) {
				this->smToolStripMenuItem,
					this->sharpeningToolStripMenuItem, this->edgeDetectionToolStripMenuItem, this->laplacianFilterToolStripMenuItem
			});
			this->filterProcessToolStripMenuItem->Name = L"filterProcessToolStripMenuItem";
			this->filterProcessToolStripMenuItem->Size = System::Drawing::Size(88, 20);
			this->filterProcessToolStripMenuItem->Text = L"Filter Process";
			// 
			// smToolStripMenuItem
			// 
			this->smToolStripMenuItem->Name = L"smToolStripMenuItem";
			this->smToolStripMenuItem->Size = System::Drawing::Size(154, 22);
			this->smToolStripMenuItem->Text = L"Smoothing";
			this->smToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::smToolStripMenuItem_Click);
			// 
			// sharpeningToolStripMenuItem
			// 
			this->sharpeningToolStripMenuItem->Name = L"sharpeningToolStripMenuItem";
			this->sharpeningToolStripMenuItem->Size = System::Drawing::Size(154, 22);
			this->sharpeningToolStripMenuItem->Text = L"Sharpening";
			this->sharpeningToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::sharpeningToolStripMenuItem_Click);
			// 
			// edgeDetectionToolStripMenuItem
			// 
			this->edgeDetectionToolStripMenuItem->Name = L"edgeDetectionToolStripMenuItem";
			this->edgeDetectionToolStripMenuItem->Size = System::Drawing::Size(154, 22);
			this->edgeDetectionToolStripMenuItem->Text = L"Edge Detection";
			this->edgeDetectionToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::edgeDetectionToolStripMenuItem_Click);
			// 
			// laplacianFilterToolStripMenuItem
			// 
			this->laplacianFilterToolStripMenuItem->Name = L"laplacianFilterToolStripMenuItem";
			this->laplacianFilterToolStripMenuItem->Size = System::Drawing::Size(154, 22);
			this->laplacianFilterToolStripMenuItem->Text = L"Laplacian Filter";
			this->laplacianFilterToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::laplacianFilterToolStripMenuItem_Click);
			// 
			// blackWhiteProcessToolStripMenuItem
			// 
			this->blackWhiteProcessToolStripMenuItem->DropDownItems->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(5) {
				this->dilationToolStripMenuItem,
					this->eroziToolStripMenuItem, this->openingToolStripMenuItem, this->closingToolStripMenuItem, this->reverseToolStripMenuItem
			});
			this->blackWhiteProcessToolStripMenuItem->Name = L"blackWhiteProcessToolStripMenuItem";
			this->blackWhiteProcessToolStripMenuItem->Size = System::Drawing::Size(147, 20);
			this->blackWhiteProcessToolStripMenuItem->Text = L"Black and White Process";
			// 
			// dilationToolStripMenuItem
			// 
			this->dilationToolStripMenuItem->Name = L"dilationToolStripMenuItem";
			this->dilationToolStripMenuItem->Size = System::Drawing::Size(120, 22);
			this->dilationToolStripMenuItem->Text = L"Dilation";
			this->dilationToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::dilationToolStripMenuItem_Click);
			// 
			// eroziToolStripMenuItem
			// 
			this->eroziToolStripMenuItem->Name = L"eroziToolStripMenuItem";
			this->eroziToolStripMenuItem->Size = System::Drawing::Size(120, 22);
			this->eroziToolStripMenuItem->Text = L"Erosion";
			this->eroziToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::eroziToolStripMenuItem_Click);
			// 
			// openingToolStripMenuItem
			// 
			this->openingToolStripMenuItem->Name = L"openingToolStripMenuItem";
			this->openingToolStripMenuItem->Size = System::Drawing::Size(120, 22);
			this->openingToolStripMenuItem->Text = L"Opening";
			this->openingToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::openingToolStripMenuItem_Click);
			// 
			// closingToolStripMenuItem
			// 
			this->closingToolStripMenuItem->Name = L"closingToolStripMenuItem";
			this->closingToolStripMenuItem->Size = System::Drawing::Size(120, 22);
			this->closingToolStripMenuItem->Text = L"Closing";
			this->closingToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::closingToolStripMenuItem_Click);
			// 
			// reverseToolStripMenuItem
			// 
			this->reverseToolStripMenuItem->Name = L"reverseToolStripMenuItem";
			this->reverseToolStripMenuItem->Size = System::Drawing::Size(120, 22);
			this->reverseToolStripMenuItem->Text = L"Reverse";
			this->reverseToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::reverseToolStripMenuItem_Click);
			// 
			// extrasToolStripMenuItem
			// 
			this->extrasToolStripMenuItem->DropDownItems->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(3) {
				this->kmeansToolStripMenuItem,
					this->connectedComponentsToolStripMenuItem, this->histogramEqualizeToolStripMenuItem
			});
			this->extrasToolStripMenuItem->Name = L"extrasToolStripMenuItem";
			this->extrasToolStripMenuItem->Size = System::Drawing::Size(50, 20);
			this->extrasToolStripMenuItem->Text = L"Extras";
			// 
			// kmeansToolStripMenuItem
			// 
			this->kmeansToolStripMenuItem->Name = L"kmeansToolStripMenuItem";
			this->kmeansToolStripMenuItem->Size = System::Drawing::Size(204, 22);
			this->kmeansToolStripMenuItem->Text = L"K-means";
			this->kmeansToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::kmeansToolStripMenuItem_Click);
			// 
			// connectedComponentsToolStripMenuItem
			// 
			this->connectedComponentsToolStripMenuItem->Name = L"connectedComponentsToolStripMenuItem";
			this->connectedComponentsToolStripMenuItem->Size = System::Drawing::Size(204, 22);
			this->connectedComponentsToolStripMenuItem->Text = L"Connected Components";
			this->connectedComponentsToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::connectedComponentsToolStripMenuItem_Click);
			// 
			// histogramEqualizeToolStripMenuItem
			// 
			this->histogramEqualizeToolStripMenuItem->Name = L"histogramEqualizeToolStripMenuItem";
			this->histogramEqualizeToolStripMenuItem->Size = System::Drawing::Size(204, 22);
			this->histogramEqualizeToolStripMenuItem->Text = L"Histogram Equalize";
			this->histogramEqualizeToolStripMenuItem->Click += gcnew System::EventHandler(this, &MyForm::histogramEqualizeToolStripMenuItem_Click);
			// 
			// label1
			// 
			this->label1->AutoSize = true;
			this->label1->Location = System::Drawing::Point(831, 81);
			this->label1->Name = L"label1";
			this->label1->Size = System::Drawing::Size(55, 13);
			this->label1->TabIndex = 3;
			this->label1->Text = L"New Size:";
			// 
			// label2
			// 
			this->label2->AutoSize = true;
			this->label2->Location = System::Drawing::Point(831, 108);
			this->label2->Name = L"label2";
			this->label2->Size = System::Drawing::Size(88, 13);
			this->label2->TabIndex = 4;
			this->label2->Text = L"Cut (x1,y1,x2,y2):";
			// 
			// label3
			// 
			this->label3->AutoSize = true;
			this->label3->Location = System::Drawing::Point(831, 135);
			this->label3->Name = L"label3";
			this->label3->Size = System::Drawing::Size(69, 13);
			this->label3->TabIndex = 5;
			this->label3->Text = L"Filter Size (x):";
			// 
			// label4
			// 
			this->label4->AutoSize = true;
			this->label4->Location = System::Drawing::Point(831, 165);
			this->label4->Name = L"label4";
			this->label4->Size = System::Drawing::Size(67, 13);
			this->label4->TabIndex = 6;
			this->label4->Text = L"Cluster Num:";
			// 
			// label5
			// 
			this->label5->AutoSize = true;
			this->label5->Location = System::Drawing::Point(831, 187);
			this->label5->Name = L"label5";
			this->label5->Size = System::Drawing::Size(93, 26);
			this->label5->TabIndex = 7;
			this->label5->Text = L"Structural Element\r\n(0:Plus,1:Square):";
			// 
			// textBox1
			// 
			this->textBox1->Location = System::Drawing::Point(930, 78);
			this->textBox1->Name = L"textBox1";
			this->textBox1->Size = System::Drawing::Size(72, 20);
			this->textBox1->TabIndex = 8;
			this->textBox1->Text = L"300,300";
			// 
			// textBox2
			// 
			this->textBox2->Location = System::Drawing::Point(930, 108);
			this->textBox2->Name = L"textBox2";
			this->textBox2->Size = System::Drawing::Size(72, 20);
			this->textBox2->TabIndex = 9;
			this->textBox2->Text = L"0,0,150,150";
			// 
			// textBox3
			// 
			this->textBox3->Location = System::Drawing::Point(930, 135);
			this->textBox3->Name = L"textBox3";
			this->textBox3->Size = System::Drawing::Size(72, 20);
			this->textBox3->TabIndex = 10;
			this->textBox3->Text = L"3";
			// 
			// textBox4
			// 
			this->textBox4->Location = System::Drawing::Point(930, 165);
			this->textBox4->Name = L"textBox4";
			this->textBox4->Size = System::Drawing::Size(72, 20);
			this->textBox4->TabIndex = 11;
			this->textBox4->Text = L"4";
			// 
			// textBox5
			// 
			this->textBox5->Location = System::Drawing::Point(930, 193);
			this->textBox5->Name = L"textBox5";
			this->textBox5->Size = System::Drawing::Size(72, 20);
			this->textBox5->TabIndex = 12;
			this->textBox5->Text = L"1";
			// 
			// label6
			// 
			this->label6->AutoSize = true;
			this->label6->Location = System::Drawing::Point(13, 48);
			this->label6->Name = L"label6";
			this->label6->Size = System::Drawing::Size(59, 13);
			this->label6->TabIndex = 13;
			this->label6->Text = L"Image Size";
			// 
			// label7
			// 
			this->label7->AutoSize = true;
			this->label7->Location = System::Drawing::Point(616, 48);
			this->label7->Name = L"label7";
			this->label7->Size = System::Drawing::Size(0, 13);
			this->label7->TabIndex = 14;
			// 
			// label8
			// 
			this->label8->AutoSize = true;
			this->label8->Location = System::Drawing::Point(831, 227);
			this->label8->Name = L"label8";
			this->label8->Size = System::Drawing::Size(43, 13);
			this->label8->TabIndex = 15;
			this->label8->Text = L"Thresh:";
			// 
			// textBox6
			// 
			this->textBox6->Location = System::Drawing::Point(930, 220);
			this->textBox6->Name = L"textBox6";
			this->textBox6->Size = System::Drawing::Size(72, 20);
			this->textBox6->TabIndex = 16;
			this->textBox6->Text = L"127";
			// 
			// MyForm
			// 
			this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->ClientSize = System::Drawing::Size(1050, 629);
			this->Controls->Add(this->textBox6);
			this->Controls->Add(this->label8);
			this->Controls->Add(this->label7);
			this->Controls->Add(this->label6);
			this->Controls->Add(this->textBox5);
			this->Controls->Add(this->textBox4);
			this->Controls->Add(this->textBox3);
			this->Controls->Add(this->textBox2);
			this->Controls->Add(this->textBox1);
			this->Controls->Add(this->label5);
			this->Controls->Add(this->label4);
			this->Controls->Add(this->label3);
			this->Controls->Add(this->label2);
			this->Controls->Add(this->label1);
			this->Controls->Add(this->pictureBox1);
			this->Controls->Add(this->menuStrip1);
			this->MainMenuStrip = this->menuStrip1;
			this->Name = L"MyForm";
			this->StartPosition = System::Windows::Forms::FormStartPosition::CenterScreen;
			this->Text = L"Image Processing";
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->pictureBox1))->EndInit();
			this->menuStrip1->ResumeLayout(false);
			this->menuStrip1->PerformLayout();
			this->ResumeLayout(false);
			this->PerformLayout();

		}
#pragma endregion
	private: System::Void openToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
		OpenFileDialog^ openFileDialog1 = gcnew OpenFileDialog;		
		openFileDialog1->InitialDirectory = this->basePath;
		openFileDialog1->ShowDialog();		
		this->readImage(openFileDialog1->FileName);
	}
private: System::Void saveToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {	
	SaveFileDialog^ saveFileDialog1 = gcnew SaveFileDialog;	
	saveFileDialog1->InitialDirectory = this->basePath;
	saveFileDialog1->ShowDialog();	
	this->writeImage(saveFileDialog1->FileName);
}
private: System::Void rGB2GRAYToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->convertToGray();
	this->refreshScreen();	
}
private: System::Void resizeToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->resizeImage();
	this->refreshScreen();
}
private: System::Void cutToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->cutImage();
	this->refreshScreen();
}
private: System::Void thresholdToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->thresholdBinary();
	this->refreshScreen();
}
private: System::Void otsuThresholdToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->threshOtsu();
	this->refreshScreen();
}
private: System::Void smToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->smoothing();
	this->refreshScreen();
}
private: System::Void sharpeningToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->sharpening();
	this->refreshScreen();
}
private: System::Void edgeDetectionToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->edgeDetection();
	this->refreshScreen();
}
private: System::Void laplacianFilterToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->laplacian();
	this->refreshScreen();
}
private: System::Void dilationToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->dilation();
	this->refreshScreen();
}
private: System::Void eroziToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->erode();
	this->refreshScreen();
}
private: System::Void openingToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->opening();
	this->refreshScreen();
}
private: System::Void closingToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->closing();
	this->refreshScreen();
}
private: System::Void reverseToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->reverse();
	this->refreshScreen();
}
private: System::Void kmeansToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->kmeans();
	this->refreshScreen();
}
private: System::Void connectedComponentsToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->connComp();
	this->refreshScreen();
}
private: System::Void histogramEqualizeToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
	this->histEqual();
	this->refreshScreen();
}
};
}
