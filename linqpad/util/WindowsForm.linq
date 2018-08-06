<Query Kind="Program">
  <Reference>&lt;RuntimeDirectory&gt;\System.Windows.Forms.dll</Reference>
  <Namespace>System.Windows.Forms</Namespace>
</Query>

void Main()
{
	System.Windows.Forms.FlowLayoutPanel FlowLayoutPanel = new System.Windows.Forms.FlowLayoutPanel();
    System.Windows.Forms.Form Form = new System.Windows.Forms.Form();
    
	System.Windows.Forms.Button Button1 = new System.Windows.Forms.Button();
	Button1.Text = "Button";
	Button1.Click += (o,e) => { System.Type typeO = o.GetType(); System.Type typeE = e.GetType(); MessageBox.Show(typeO.ToString() + "\n" + typeE.ToString()); };
	Form.Controls.Add(Button1);
	
	Form.Show();
}

// Define other methods and classes here
