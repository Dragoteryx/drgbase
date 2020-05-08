export class LuaType {
  public readonly Table: LuaTable;
  public constructor(public readonly name: string, public readonly reference: string) {
    this.Table = new LuaTable(this);
  }
}

export class LuaTable extends LuaType {
  public constructor(public readonly contains: LuaType) {
    super("table", "https://www.lua.org/pil/2.4.html");
  }
}

export const LuaNil = new LuaType("nil", "https://www.lua.org/pil/2.1.html");
export const LuaBool = new LuaType("boolean", "https://www.lua.org/pil/2.2.html");
export const LuaNumber = new LuaType("number", "https://www.lua.org/pil/2.2.html");
export const LuaString = new LuaType("string", "https://www.lua.org/pil/2.3.html");