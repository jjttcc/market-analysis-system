note
    description:
        "A command that responds to a client request for a list of all %
        %indicators currently known to the system"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class OBJECT_INFO_REQUEST_CMD inherit

    TRADABLE_REQUEST_COMMAND
        redefine
        end

    GLOBAL_APPLICATION
        export
            {NONE} all
        end

inherit {NONE}
    STRING_UTILITIES
        rename
            make as su_make_unused
        export
            {NONE} all
        end

creation

    make

feature {NONE} -- Basic operations

    do_execute(message: ANY)
        local
            msg: STRING
            records: LIST [STRING]
            fields: LIST [STRING]
        do
            msg := message.out
            parse_error := False
            target := msg -- set up for tokenization
            records := tokens(message_record_separator)
            error_msg := ""
            response := ""
            across records as record loop
                create reported.make_equal(10)
                debugging := False
                html_on := False
                recursive := False
                full_recursion := False
                level := 0
                target := record.item
                fields := tokens(message_sub_field_separator)
                add_response_for_processor(fields)
                response := response + object_separator.out
            end
            if not parse_error then
                response.remove_tail(1) -- Remove final 'object_separator'
                send_response
            else
                report_error(Error, <<error_msg>>)
            end
        end

feature {NONE} -- Implementation - attributes and constants

    object_separator: CHARACTER = '%/0x1A/' -- Ctrl+Z

    parse_error: BOOLEAN
            -- Did a parse error occur?

    error_msg: STRING

    minimum_field_count: INTEGER = 2

    response: STRING

    indicator_tag: STRING = "indicator"

    generator_tag: STRING = "event-generator"

    debugging: BOOLEAN
            -- Has debug-level detail been requested?

    html_on: BOOLEAN
            -- Is the response to be in html format?

    recursive: BOOLEAN
            -- Is the response to include a recursive report of the
            -- object/function tree?

    full_recursion: BOOLEAN
            -- Is the response to include a full recursive report (i.e.,
            -- all redundant branches included) of the object/function tree?

    opts_detail: STRING = "detail"

    opts_debug: STRING = "debug"

    opts_html: STRING = "html"

    opts_recursive: STRING = "recursive"

    opts_recursive_full: STRING = "full-recursion"

    reported: HASH_TABLE [LIST [ANY], TYPE [ANY]]
            -- Record of objects that have already been reported

feature {NONE} -- Implementation

    add_response_for_processor(fields: LIST [STRING])
        require
            fields_exist: fields /= Void
            err_msg_set: error_msg /= Void
            response_set: response /= Void
        local
            processor: TRADABLE_PROCESSOR
            invalid_name: BOOLEAN
            opt_fields: LIST [STRING]
        do
            if fields.count < minimum_field_count then
                parse_error := True
                error_msg := error_msg + "Format error: too few fields"
                if fields.count > 0 then
                    error_msg := error_msg + ": '"
                    error_msg := error_msg + fields[1] + "'"
                end
                error_msg := error_msg + "%N"
            else
                if fields.count > 2 then
                    target := fields[3]
                    opt_fields := tokens(";")
                    across opt_fields as opt loop
                        if opt.item ~ opts_html then
                            html_on := True
                        elseif opt.item ~ opts_recursive then
                            recursive := True
                        elseif opt.item ~ opts_recursive_full then
                            recursive := True
                            full_recursion := True
                        elseif opt.item ~ opts_debug then
                            debugging := True
                        end
                    end
                end
                if fields[1] ~ indicator_tag then
                    processor := tradables.indicator_with_name(fields[2])
                    invalid_name := processor = Void
                elseif fields[1] ~ generator_tag then
                    processor := event_generator_with_name(fields[2])
                    invalid_name := processor = Void
                else
                    parse_error := True
                    error_msg := error_msg +
                        "Invalid object type: '" + fields[1] + "'%N"
                end
                if invalid_name then
                    parse_error := True
                    error_msg := error_msg + "Invalid name for " +
                        fields[1] + ": " + fields[2] + "%N"
                end
            end
            if not parse_error then
                response := response + block(report_for(processor, False))
            end
        ensure
            response /= Void
        end

    send_response
        do
            put_ok
            put(response)
            put(eom)
        end

    report_for(proc: TRADABLE_PROCESSOR; suppress_header: BOOLEAN): STRING
            -- Information about `proc'
        require
            proc_exists: proc /= Void
        do
            Result := ""
            if not suppress_header then
                Result := "%N" + heading(proc.name, True)
                Result := Result + increment_level
                Result := Result + block(period_type_report(proc))
            end
            Result := Result + block(functions_report(proc))
            Result := Result + block(operators_report(proc))
            Result := Result + block(parameters_report(proc))
            if not suppress_header then
                Result := Result + decrement_level
            end
        ensure
            result_exists: Result /= Void
        end

    functions_report(proc: TRADABLE_PROCESSOR): STRING
        require
            proc_exists: proc /= Void
        local
            fcount, rep_fcount: INTEGER
            tmp: STRING
        do
            tmp := ""
            Result := ""
            across proc.functions as fcursor loop
                if fcursor.item /= proc then
                    if was_not_reported(fcursor.item) then
                        tmp := tmp + function_parameter_report(fcursor.item,
                                                               True, recursive)
                        rep_fcount := rep_fcount + 1
                    elseif level < 2 then
                        -- Top level and fcursor.item was already reported,
                        -- so don't recurse.
                        tmp := tmp + function_parameter_report(fcursor.item,
                                                               True, False)
                        rep_fcount := rep_fcount + 1
                    end
                    fcount := fcount + 1
                end
            end
            if fcount > 0 then
                Result := indented(fcount.out + " " +
                                   pluralized("function", fcount) + ":")
                if fcount > rep_fcount then
                    --("Abbreviate" redundant branch.)
                    tmp := tmp + block("...")
                end
                Result := Result + increment_level + tmp + decrement_level
            end
        ensure
            result_exists: Result /= Void
        end

    operators_report(proc: TRADABLE_PROCESSOR): STRING
        require
            proc_exists: proc /= Void
        local
            i: INTEGER
        do
            Result := indented(proc.operators.count.out + " " +
                   pluralized("operator", proc.operators.count) + ":")
            i := 1
            Result := Result + increment_level
            if debugging then
                Result := Result + block(code("[", proc.operators.out, "]"))
            end
            across proc.operators as fcursor loop
                Result := Result + command_report(fcursor.item, i)
                i := i + 1
            end
            Result := Result + decrement_level
        ensure
            result_exists: Result /= Void
        end

    parameters_report(proc: TRADABLE_PROCESSOR): STRING
        require
            proc_exists: proc /= Void
        do
            Result := indented(proc.parameters.count.out + " " +
                pluralized("parameter", proc.parameters.count) + ":")
            Result := Result + increment_level
            across proc.parameters as fcursor loop
                Result := Result + function_parameter_report(fcursor.item,
                                                             False, False)
            end
            Result := Result + decrement_level
        ensure
            result_exists: Result /= Void
        end

    function_parameter_report(f: FUNCTION_PARAMETER; as_function: BOOLEAN;
                              recurse: BOOLEAN): STRING
        require
            f_exists: f /= Void
        local
            fname: STRING
        do
            Result := ""
            if f.name.is_empty then
                fname := f.verbose_name
            else
                fname := f.name
            end
            if fname ~ f.verbose_name.substring(1, fname.count) then
                -- Include the name only if it differs from the beginning
                -- of f.verbose_name.
                fname := ""
            else
                fname := fname + ": "
            end
            Result := Result + block(heading(fname + f.verbose_name,
                                             as_function))
            Result := Result + increment_level
            if not as_function and then not f.current_value.is_empty then
                Result := Result + block(indented("value: " + f.current_value))
            end
            if
                (not as_function or debugging) and
                f.value_type_description /~ f.generating_type
            then
                Result := Result + block(indented("type: " +
                                         f.value_type_description))
            end
            if
                debugging and not f.out.is_empty and
                f.out.count < max_output_size
            then
                if as_function then
                    Result := Result + block(code("[", f.out, "]"))
                else
                    Result := Result + block("[" + f.out + "]")
                end
            end
            if recurse and as_function then
                Result := Result + recursive_report_for(f)
            end
            Result := Result + decrement_level
        ensure
            result_exists: Result /= Void
        end

    command_report(c: COMMAND; opnum: INTEGER): STRING
        local
            cmd_name: STRING
        do
            Result := ""
            if c = Void then
                if debugging then
                    Result := Result + block(indented("(Operator " +
                        opnum.out + " is Void)"))
                end
            else
                cmd_name := c.name
                if cmd_name = Void or else cmd_name.is_empty then
                    cmd_name := c.user_friendly_name
                end
                Result := Result + block(indented(cmd_name))
                if debugging then
                    Result := Result + increment_level
                    Result := Result + block(code("[", c.out, "]"))
                    Result := Result + decrement_level
                end
            end
        ensure
            result_exists: Result /= Void
        end

    period_type_report(proc: TRADABLE_PROCESSOR): STRING
            -- Period-type information, if any, for proc
        require
            proc_exists: proc /= Void
        do
            Result := ""
            if attached {FUNCTION_ANALYZER} proc as fana then
                Result := indented("period type: " +
                    fana.period_type.name)
                if debugging then
                    Result := Result + block(code("[",
                        fana.period_type.out, "]"))
                end
            else
                Result := indented("period type: [None]")
            end
        ensure
            result_exists: Result /= Void
        end

    recursive_report_for(fp: FUNCTION_PARAMETER): STRING
            -- If 'fp' is eligible for a recursive report, the result of
            -- calling report_for(fp, True); otherwise, an empty string
            -- (The purpose of this function is to ensure that recursive
            -- function reports are not redundant - i.e., that an object
            -- that would otherwise be reported more than once [as a descendant
            -- in the function tree] is only reported the first time it is seen
            -- as a descendant.  The goal is to prevent wasted space, time,
            -- and user readability.)
        require
            needed_items_exist: reported /= Void and fp /= Void
        local
            not_reported: BOOLEAN
        do
            Result := ""
            not_reported := was_not_reported(fp)
            if not_reported then
                -- (If `full_recursion', never mark an object as "reported".)
                if not full_recursion then set_reported(fp) end
                if attached {COMPLEX_FUNCTION} fp as proc then
                    Result := Result + report_for(proc, True)
                end
            end
        ensure
            not_void: Result /= Void
            reported_side_effect: not full_recursion = not was_not_reported(fp)
        end

    set_reported(fp: FUNCTION_PARAMETER)
            -- Mark `fp' as "reported".
        require
            needed_items_exist: reported /= Void and fp /= Void
        local
            replist: LIST [ANY]
        do
            replist := reported[fp.generating_type]
            if replist = Void then
                create {LINKED_LIST [ANY]} replist.make
                reported.extend(replist, fp.generating_type)
            end
            replist.extend(fp)
        ensure
            as_promised: not was_not_reported(fp)
        end

    was_not_reported(object: ANY): BOOLEAN
        local
            replist: LIST [ANY]
        do
            replist := reported[object.generating_type]
            Result := replist = Void or else not replist.has(object)
        end

feature {NONE} -- formatting/html

    level: INTEGER
            -- Current level with respect to object-component hierarchy

    tab_size: INTEGER = 3

    max_output_size: INTEGER = 1024

    indent_space: STRING
        local
            indent: STRING
        do
            create indent.make_filled(' ', tab_size)
            Result := ""
            across 1 |..| level as x loop
                Result := Result + indent
            end
        ensure
            result_exists: Result /= Void
        end

    indented(s: STRING): STRING
        local
            indentation: STRING
            fields: LIST [STRING]
        do
            Result := ""
            indentation := indent_space
            target := s
            fields := tokens("%N")
            across fields as f loop
                -- (Skip lines that are all white space.)
                if not f.item.is_whitespace then
                    f.item.right_adjust
                    Result := Result + indentation + f.item + "%N"
                end
            end
        end

    heading(s: STRING; strong: BOOLEAN): STRING
        local
            h: STRING
        do
            if level = 0 then
                h := "h3"
            else
                if strong then
                    h := "strong"
                else
                    h := "em"
                end
            end
            Result := indented("<" + h + ">" + s + "</" + h + ">")
        end

    css_class_base: STRING = "masinfo"

    list_start: STRING
        do
            Result := "%N<ul class='" + current_class + "'>"
        end

    list_end: STRING
        do
            Result := "%N</ul class='" + current_class + "'>"
        end

    list_item_open: STRING
        do
            Result := "%N<li class='" + current_class + "'>"
        end

    list_item_closed: STRING
        do
            Result := "%N</li class='" + current_class + "'>"
        end

    outer_block_open: STRING
        do
            Result := "%N<div class='" + current_class + "'>"
        end

    outer_block_closed: STRING
        do
            Result := "%N</div class='" + current_class + "'>"
        end

    code_item_open: STRING
        do
            Result := "<pre class='" + current_class + "'>"
        end

    code_item_closed: STRING
        do
            Result := "</pre class='" + current_class + "'>"
        end

    increment_level: STRING
        do
            Result := ""
            if html_on then
                Result := Result + list_start
            end
            level := level + 1
        end

    decrement_level: STRING
        do
            Result := ""
            if html_on then
                Result := Result + list_end
            end
            level := level - 1
        end

    block(content: STRING): STRING
            -- If formatting is enabled: `content' embedded in a format
            -- block; otherwise `content', unmodified
        do
            Result := content
            if html_on then
                if level > 0 then
                    Result := list_item_open + content + list_item_closed
                else
                    Result := outer_block_open + content + outer_block_closed
                end
            end
        end

    code(prefx, content, suffx: STRING): STRING
        require
            args_exist: prefx /= Void and then content /= Void and then
                suffx /= Void
        do
            Result := content
            Result.right_adjust
            Result := prefx + Result + suffx
            if html_on then
                Result := code_item_open + Result + code_item_closed
            end
        end

    current_class: STRING
        do
            Result := css_class_base + level.out
        end

    objid(o: ANY): STRING
            -- id extracted from 'o.out' (for debugging)
        require
            o: o /= Void
        local
        do
            Result := o.out.hash_code.out
        end

invariant

    sane_level: level >= 0
    reported_objcomp: reported /= Void implies reported.object_comparison

end
