use BD2;
drop function if exists getProfileId
create function getProfileId()
    returns int
    as
    begin
        declare @resultado int
        select @resultado = max(id) from practica1.ProfileStudent
        if (@resultado is null )
            set @resultado = 0
        else
            set @resultado=@resultado+1
        return @resultado
end


drop procedure if exists TR1;
create or alter procedure TR1
    @first varchar(100), @last varchar(100), @mail nvarchar(max),
    @pass nvarchar(max), @credits int
as
    declare
        @idUsuarios uniqueidentifier, @lastMod datetime, @roleId uniqueidentifier,@mensaje nvarchar(max)
    set @idUsuarios = newid() set @lastMod = SYSUTCDATETIME()
    begin try
        begin tran
        select @roleId = id from practica1.Roles where RoleName='Student';
        if @first is null or @mail is null or @pass is null or @credits is null
            set @mensaje= 'uno de los parametos es nulo y se requiere su valor TR1'
        else if @mail  not in (select Email from practica1.Usuarios)
            begin
                insert into practica1.Usuarios(Id, Firstname, Lastname, Email, DateOfBirth, Password, LastChanges, EmailConfirmed)
                values (@idUsuarios,@first,@last,@mail,GETDATE(),@pass,@lastMod,0);
                insert into practica1.UsuarioRole(RoleId, UserId, IsLatestVersion) values (@roleId,@idUsuarios,0);
                insert into practica1.ProfileStudent(UserId, Credits) values (@idUsuarios,@credits);
                insert into practica1.TFA(UserId, Status, LastUpdate) values (@idUsuarios,0,@lastMod)
                insert into practica1.Notification(UserId, Message, Date) values (@idUsuarios,'Usuario registrado, por favor verifique su correo',@lastMod)
                set @mensaje='Transaccion exitosa TR1'
            end
        else
            set @mensaje= 'No se a realizado el login, correo repetido TR1'
        insert into practica1.HistoryLog(Date, Description) values (getdate(),@mensaje)
        commit tran
    end try
    begin catch
        print 'ocurrio un error en la transaccion'
end catch

drop procedure if exists TR2;
create or alter procedure TR2
    @mail nvarchar(max), @curseCod int
as
        declare @idUsuario uniqueidentifier, @rol uniqueidentifier, @mensaje nvarchar(max)
        begin try
            begin tran
            select @idUsuario = id from practica1.Usuarios where Email=@mail;
            select @rol = id from practica1.Roles where RoleName='Tutor';
            if @mail is null or @curseCod is null
                set @mensaje= 'Uno de los parametros es nulo, revise TR2'
            else if ((select EmailConfirmed from practica1.Usuarios where Id=@idUsuario) =0)
                set @mensaje= 'El usuario no ha confirmado su correo, revise TR2'
            else if @mail not in (select Email from practica1.Usuarios where id=@idUsuario)
                set @mensaje= 'El correo ingresado no esta registrado TR2'
            else if @curseCod in (select CodCourse from practica1.Course)
                begin
                    insert into practica1.UsuarioRole(RoleId, UserId, IsLatestVersion) values (@rol,@idUsuario,0);
                    insert into practica1.TutorProfile(UserId, TutorCode) values (@idUsuario,'7373');
                    insert into practica1.CourseTutor(TutorId, CourseCodCourse) values (@idUsuario,@curseCod);
                    insert into practica1.Notification(UserId, Message, Date) values (@idUsuario,'Tutor agregado con exito',SYSUTCDATETIME());
                    set @mensaje='Transaccion exitosa TR2'
                end
            else
                print 'El codigo del curso no existe'
            insert into practica1.HistoryLog(Date, Description) values (getdate(),@mensaje)
            commit tran
        end try
        begin catch
            print 'ocurrio un error en la transaccion'
        end catch


drop procedure if exists TR3;
create or alter procedure TR3
    @email nvarchar(max), @curseCod int
as
    declare @idUsuario uniqueidentifier, @masterId nvarchar(max),@nombreCurso nvarchar(max),
        @userName nvarchar(max),@mensaje nvarchar(max)
    begin try
        begin tran
            select @idUsuario = id from practica1.Usuarios where Email=@email
            select @masterId = TutorId from practica1.CourseTutor where CourseCodCourse=@curseCod;
            select @nombreCurso = Name from practica1.Course where CodCourse=@curseCod;
            select @userName = firstName from practica1.Usuarios where Id=@idUsuario;
            if @email not in (select Email from practica1.Usuarios)
                set @mensaje= 'Correo de usuario no esta registrado TR3'
            else if @curseCod not in (select CodCourse from practica1.Course)
                set @mensaje= 'Codigo del curso no existe TR3'
            else if ((select EmailConfirmed from practica1.Usuarios where Id=@idUsuario) =0)
                set @mensaje= 'Correo de usuario no confirmado TR3'
            else if ((select Credits from practica1.ProfileStudent where UserId=@idUsuario)<
                     (select CreditsRequired from practica1.Course where CodCourse=@curseCod))
                set @mensaje= 'El alumno no cumple con los reditos minimos para el curso TR3'
            else
                begin
                    insert into practica1.CourseAssignment(StudentId, CourseCodCourse) values
                    (@idUsuario,@curseCod);
                    insert into practica1.Notification(UserId, Message, Date) values (@idUsuario,
                            concat('Fue asignado al curso: ',@nombreCurso),getdate())
                    if @masterId in (select TutorId from practica1.CourseTutor)
                        insert into practica1.Notification(UserId, Message, Date) values (@masterId,
                            concat('Nuevo registro a su curso de: ',@userName),getdate())
                    set @mensaje='Transaccion exitosa TR3'
                end
        insert into practica1.HistoryLog(Date, Description) values (getdate(),@mensaje)
        commit tran
    end try
    begin catch
        print 'ocurrio un error en la transaccion'
    end catch
