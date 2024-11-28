import System
import System.Diagnostics
import System.Windows.Forms
import System.Drawing
import System.ServiceProcess

class ProcessInspector(Form):
    private _listView as ListView
    
    def constructor():
        self.Text = "Process Inspector"
        self.Size = System.Drawing.Size(1200, 800)  # Larger window for more columns
        self.StartPosition = FormStartPosition.CenterScreen
        InitializeComponents()
        PopulateProcessList()
    
    private def InitializeComponents():
        _listView = ListView()
        _listView.Dock = DockStyle.Fill
        _listView.View = View.Details
        _listView.FullRowSelect = true
        _listView.GridLines = true
        
        # Enhanced columns
        _listView.Columns.Add("Process Name", 150)
        _listView.Columns.Add("PID", 80)
        _listView.Columns.Add("Session ID", 80)
        _listView.Columns.Add("Protection Level", 100)
        _listView.Columns.Add("Handle Count", 100)
        _listView.Columns.Add("Thread Count", 100)
        _listView.Columns.Add("Memory Usage (MB)", 120)
        
        self.Controls.Add(_listView)
        
        refreshButton = Button()
        refreshButton.Text = "Refresh"
        refreshButton.Dock = DockStyle.Bottom
        refreshButton.Click += RefreshProcessList
        self.Controls.Add(refreshButton)
    
    private def GetProtectionLevel(process as Process) as string:
        try:
            if process.Handle != IntPtr.Zero:
                if process.PriorityClass == ProcessPriorityClass.High:
                    return "Protected"
                elif process.PriorityClass == ProcessPriorityClass.RealTime:
                    return "System"
                return "Normal"
        except:
            pass
        return "Unknown"
    
    private def PopulateProcessList():
        _listView.Items.Clear()
        
        try:
            processes = Process.GetProcesses()
            
            for process in processes:
                try:
                    item = ListViewItem(process.ProcessName)
                    item.SubItems.Add(process.Id.ToString())
                    item.SubItems.Add(process.SessionId.ToString())
                    item.SubItems.Add(GetProtectionLevel(process))
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