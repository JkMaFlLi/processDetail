import System
import System.Diagnostics
import System.Windows.Forms
import System.Drawing

class ProcessInspector(Form):
    private _listView as ListView
    
    def constructor():
        self.Text = "Process Inspector"
        self.Size = System.Drawing.Size(800, 600)
        self.StartPosition = FormStartPosition.CenterScreen
        InitializeComponents()
        PopulateProcessList()
    
    private def InitializeComponents():
        # Initialize ListView
        _listView = ListView()
        _listView.Dock = DockStyle.Fill
        _listView.View = View.Details
        _listView.FullRowSelect = true
        _listView.GridLines = true
        
        # Add columns
        _listView.Columns.Add("Process Name", 200)
        _listView.Columns.Add("PID", 100)
        _listView.Columns.Add("Handle Count", 100)
        _listView.Columns.Add("Thread Count", 100)
        _listView.Columns.Add("Memory Usage (MB)", 120)
        
        # Add ListView to form
        self.Controls.Add(_listView)
        
        # Add refresh button
        refreshButton = Button()
        refreshButton.Text = "Refresh"
        refreshButton.Dock = DockStyle.Bottom
        refreshButton.Click += RefreshProcessList
        self.Controls.Add(refreshButton)
    
    private def PopulateProcessList():
        _listView.Items.Clear()
        
        try:
            processes = Process.GetProcesses()
            
            for process in processes:
                try:
                    item = ListViewItem(process.ProcessName)
                    item.SubItems.Add(process.Id.ToString())
                    item.SubItems.Add(process.HandleCount.ToString())
                    item.SubItems.Add(process.Threads.Count.ToString())
                    memoryMB = (process.WorkingSet64 / 1024 / 1024).ToString("N2")
                    item.SubItems.Add(memoryMB)
                    
                    _listView.Items.Add(item)
                except:
                    continue # Skip processes we can't access
        except ex as Exception:
            MessageBox.Show("Error loading process list: " + ex.Message)
    
    private def RefreshProcessList(sender as object, e as EventArgs):
        PopulateProcessList()

[STAThread]
def Main():
    Application.EnableVisualStyles()
    Application.SetCompatibleTextRenderingDefault(false)
    Application.Run(ProcessInspector())

Main()