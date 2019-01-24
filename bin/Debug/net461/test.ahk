#Include CLR.ahk

c# =
(
namespace test
{
    public class Class1
    {
        public int increase(int var)
        {
            var++;
            return var;
        }
    }
}
)
CLR_Start()
asm := CLR_CompileC#(c#, "")
obj1 := CLR_CreateObject(asm, "test.Class1")
MsgBox % obj1.increase( 123)