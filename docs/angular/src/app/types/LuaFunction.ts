import { LuaType, LuaNil } from './LuaType';

export interface LuaFunctionArgument {
  readonly name: string;
  readonly type: LuaType;
  readonly optional?: boolean;
}

export class LuaFunction extends LuaType {
  public constructor(public readonly args: LuaFunctionArgument[], public readonly returns: LuaType = LuaNil) {
    super("Function", "https://www.lua.org/pil/2.5.html");
  }
}